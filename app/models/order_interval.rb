class OrderInterval < ApplicationRecord
  include AASM
  has_ancestry

  belongs_to :balance_interval
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
    event :status_traded, after: :after_status_traded do
      transitions :from => :status_trading, :to => :status_traded
    end
    event :status_closed do
      transitions :from => [:status_created, :status_trading, :status_traded], :to => :status_closed
    end
    event :status_canceled, after_commit: :after_commit_status_canceled do
      transitions :from => [:status_created, :status_trading], :to => :status_canceled
    end
  end

  def after_status_trading
    # make order
    side = category == 'category_buy' ? 'buy' : 'sell'
    order = Order.api_make(balance_interval.balance.account, balance_interval.trade_symbol, side, price, amount, 'kind_interval')
    if order
      order.update(tradable: self, balancable: balance_interval)
    else
      raise "#{balance_interval.trade_symbol.base_currency}[amount:#{balance_interval.amount}] make #{side} order error. will try."
    end
  end

  def after_status_traded
    # 如果是买入成功，需要下单卖出
    if self.category == 'category_buy'
      sell_amount = self.order.resolve_amount
      sell_order_interval = balance_interval.order_intervals.create(price: balance_interval.sell_price, amount: sell_amount, category: 'category_sell')
      if sell_order_interval.may_status_trading?
        sell_order_interval.status_trading!
        self.update(parent: sell_order_interval)
      end
    # 如果是卖出需要计算利润
    else # category_sell
      # 只会有一个孩子
      sell_order = self.order
      self.children.each do |buy_order_interval|
        buy_order_interval.order.update(parent: sell_order)
      end
      sum_children_price = self.children.status_traded.inject(0) { |sum, child| sum + child.order.price * child.field_amount }
      field_profit = sell_order.price * sell_order.field_amount - sell_order.field_fees - sum_children_price
      sell_order.update(field_profit: field_profit)
    end
    # 发送买入卖出通知
    self.order.send_traded_notification
  end

  def after_commit_status_canceled
    # 如果取消的卖出订单需要重新下单
    if self.category == 'category_sell'
      sell_amount = self.children.status_traded.inject(0) { |sum, child| sum + child.order.resolve_amount }
      sell_order_interval = balance_interval.order_intervals.create(price: balance_interval.sell_price, amount: sell_amount, category: 'category_sell')
      if sell_order_interval.may_status_trading?
        sell_order_interval.status_trading!
        self.children.each do |buy_order_interval|
          buy_order_interval.update(parent: sell_order_interval)
        end
      end
    end
  end
end
