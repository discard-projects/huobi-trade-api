class OrderPlan < ApplicationRecord
  include AASM
  has_ancestry

  belongs_to :balance_plan
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
    event :status_canceled, after_commit: :after_commit_status_canceled do
      transitions :from => [:status_created, :status_trading], :to => :status_canceled
    end
  end

  def try_cancel!
    user = self.balance_plan.user
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

  def after_status_trading
    # make order
    side = category == 'category_buy' ? 'buy' : 'sell'
    price = category == 'category_buy' ? should_buy_price : sell_price
    amount = category == 'category_buy' ? buy_amount : sell_amount
    order = Order.api_make!(balance_plan.balance.account, balance_plan.trade_symbol, side, price , amount, 'kind_plan')
    if order
      order.update(tradable: self, balancable: balance_plan)
    else
      raise "plan: #{balance_plan.trade_symbol.base_currency}[amount:#{balance_plan.amount}] make #{side} order error. will try."
    end
  end

  def after_status_traded
    # 如果是买入成功，需要下单卖出
    if self.category == 'category_buy'
      sell_amount = self.order.resolve_amount
      sell_order_plan = balance_plan.order_plans.create(sell_price: self.sell_price, sell_amount: sell_amount, category: 'category_sell')
      if sell_order_plan.may_status_trading?
        sell_order_plan.status_trading!
        self.update(parent: sell_order_plan)
      end
    # 如果是卖出需要计算利润
    else # category_sell
      # 只会有一个孩子
      sell_order = self.order
      self.children.status_traded.each do |buy_order_plan|
        buy_order_plan.order.update(parent: sell_order)
      end
      sum_children_price = self.children.status_traded.inject(0) { |sum, child| sum + child.order.price * child.order.field_amount }
      field_profit = sell_order.price * sell_order.field_amount - sell_order.field_fees - sum_children_price
      sell_order.update(field_profit: field_profit)
    end
  end

  def after_commit_status_traded
    if self.category == 'category_sell'
      self.children.each do |buy_plan|
        buy_plan.status_closed! if buy_plan.may_status_closed?
      end
      self.status_closed! if self.may_status_closed?
    end
    # 发送买入卖出通知
    self.order.send_traded_notification rescue nil
  end

  def after_commit_status_canceled
    # 如果取消的卖出订单需要重新下单
    if self.category == 'category_sell'
      sell_amount = self.children.status_traded.inject(0) { |sum, child| sum + child.order.resolve_amount }
      sell_price = self.parent.sell_price
      sell_order_plan = balance_plan.order_plans.create(sell_price: sell_price, sell_amount: sell_amount, category: 'category_sell')
      if sell_order_plan.may_status_trading?
        sell_order_plan.status_trading!
        self.children.each do |buy_order_plan|
          buy_order_plan.update(parent: sell_order_plan)
        end
      end
    end
  end
end
