class BalanceSmart < ApplicationRecord
  belongs_to :balance
  belongs_to :trade_symbol
  has_many :order_smarts, dependent: :destroy
  has_many :orders, as: :balancable, dependent: :nullify

  validates :buy_percent, :sell_percent, numericality: { greater_than_or_equal_to: 0.5 }
  validates :open_price, :amount, :rate_amount, :max_amount, numericality: { greater_than: 0 }

  def user
    balance.user
  end

  def has_max_amount?
    has_amount = self.order_smarts.category_buy.status_traded.sum(:resolve_amount)
    has_amount > self.max_amount
  end

  def next_should_buy_price
    last_buyed_order_smart = self.order_smarts.category_buy.status_traded.last
    (last_buyed_order_smart && last_buyed_order_smart.price * (1 - self.buy_percent * 0.01) || self.open_price).floor(trade_symbol.price_precision)
  end

  def next_should_buy_amount
    last_buyed_order_smart = self.order_smarts.category_buy.status_traded.last
    (last_buyed_order_smart && last_buyed_order_smart.amount * (1 + self.rate_amount * 0.01) || self.amount).floor(trade_symbol.amount_precision)
  end

  def can_make_buy_order?
    current_price = trade_symbol.current_price
    # 没买到最大量     并  # 价格 <= 应该买入价格的1.005                         并 # 没有正在交易的买单                                                                       或 # 买入订单为非取消状态个数为0
    !has_max_amount? && current_price <= self.next_should_buy_price * 1.005 && self.order_smarts.category_buy.where(status: [:status_created, :status_trading]).blank? || self.order_smarts.category_buy.where.not(status: 'status_canceled').blank?
  end
  # 所有买入平均值
  def avg_price
    traded_order_smarts = self.order_smarts.category_buy.status_traded
    (traded_order_smarts.present? ? traded_order_smarts.sum(:total_price) / traded_order_smarts.sum(:amount) : self.open_price).floor(trade_symbol.price_precision)
  end

  def resolve_amount
    self.order_smarts.category_buy.status_traded.sum(:resolve_amount)
  end

  def should_sell_price
    # 向上取，一个点就为超过1%的情况
    (self.avg_price * (1 + self.sell_percent * 0.01)).ceil(trade_symbol.price_precision)
  end

  def should_sell_amount
    self.order_smarts.category_buy.status_traded.sum(:resolve_amount)
  end

  def can_make_sell_order?
    last_buy_trading = self.order_smarts.category_buy.where(status: [:status_created, :status_trading]).last
    current_price = trade_symbol.current_price

    # 如果最后下单的价格上升了1%的价格还比 比当前价格大, 就暂且不允许卖出，防止频繁下单买入卖出并取消
    return false if last_buy_trading && last_buy_trading.price * (1 + 0.01) > current_price
    self.order_smarts.category_buy.where(status: [:status_traded]).present? && self.order_smarts.category_sell.where(status: [:status_created, :status_trading, :status_traded]).blank?
  end
end
