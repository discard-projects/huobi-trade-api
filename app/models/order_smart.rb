class OrderSmart < ApplicationRecord
  include AASM
  has_ancestry

  belongs_to :balance_smart
  has_one :order, as: :tradable, dependent: :nullify

  # category buy/sell
  enum category: { category_buy: 0, category_sell: 1 }
  ransacker :category, formatter: proc { |v| categories[v] }

  # status
  enum status: { status_created: 0, status_trading: 1, status_traded: 2, status_closed: 3, status_canceled: 4 }
  ransacker :status, formatter: proc { |v| statuses[v] }

  aasm :column => :status, :enum => true do
    state :status_created, :initial => true
    state :status_trading, :status_traded, :status_closed, :status_canceled

    event :status_trading, after: :after_status_trading do
      transitions :from => :status_created, :to => :status_trading
    end
    event :status_traded, after: :after_status_traded, after_commit: :after_commit_status_traded do
      transitions :from => :status_trading, :to => :status_traded
    end
    event :status_closed do
      transitions :from => [:status_created, :status_trading, :status_traded], :to => :status_closed
    end
    event :status_canceled do
      transitions :from => [:status_created, :status_trading], :to => :status_canceled
    end
  end

  before_save :before_save


  def try_cancel!
    user = self.balance_smart.user
    huobi_api = user.huobi_api
    if huobi_api && self.order
      res = huobi_api.batchcancel([self.order.hid])
      if res['status'] == 'ok'
        self.status_canceled! if self.may_status_canceled?
      else
        raise "cancel oder[#{order.id}] failed: #{res}"
      end
    end
  end

  private

  def before_save
    self.total_price = self.price * self.amount
  end

  def after_status_trading
    # make order
    side = category == 'category_buy' ? 'buy' : 'sell'
    order = Order.api_make!(balance_smart.balance.account, balance_smart.trade_symbol, side, price, amount, 'kind_smart')
    if order
      order.update(tradable: self, balancable: balance_smart)
    else
      raise "#{balance_smart.trade_symbol.base_currency}[amount:#{balance_smart.amount}] make #{side} order error. will try."
    end
  end

  def after_status_traded
    # 如果是买入成功，需要下单卖出
    if self.category == 'category_sell'
      # 只会有一个孩子
      sell_order = self.order
      buyed_order_smarts = self.balance_smart.order_smarts.category_buy.status_traded
      sum_children_price = buyed_order_smarts.inject(0) { |sum, child| sum + child.order.price * child.order.field_amount }
      field_profit = sell_order.price * sell_order.field_amount - sell_order.field_fees - sum_children_price
      sell_order.update(field_profit: field_profit)
    end
  end

  def after_commit_status_traded
    if self.category == 'category_buy'
      # 创建卖出订单
      sell_price = self.balance_smart.should_sell_price
      sell_amount = self.balance_smart.should_sell_amount
      sell_order_smart = self.balance_smart.order_smarts.create(price: sell_price, amount: sell_amount, category: 'category_sell')
      if sell_order_smart.may_status_trading?
        sell_order_smart.status_trading!
      end
    else # self.category == 'category_sell'
      # 关闭balance_smart
      self.balance_smart.update_column(:enabled, false)
      buyed_order_smarts = self.balance_smart.order_smarts.category_buy.status_traded
      buyed_order_smarts.each do |buyed_order_smart|
        buyed_order_smart.status_closed! if buyed_order_smart.may_status_closed?
      end
      self.status_closed! if self.may_status_closed?
    end
    # 发送买入卖出通知
    self.order.send_traded_notification rescue nil
  end
end
