class BalanceSmart < ApplicationRecord
  belongs_to :balance
  belongs_to :trade_symbol
  has_many :order_smarts, dependent: :destroy
  has_many :orders, as: :balancable, dependent: :nullify

  def next_should_buy_price
    (self.order_smarts.category_buy.status_traded.last.price * (1 - self.buy_percent * 0.01) || self.open_price).floor(trade_symbol.price_precision)
  end

  def next_should_buy_amount
    (self.order_smarts.category_buy.status_traded.last.amount * (1 + self.sell_percent * 0.01)).floor(trade_symbol.amount_precision)
  end

  def can_make_buy_order?
    current_price = trade_symbol.current_price
    last_buy_price = self.order_smarts.category_buy.status_traded.last.price
    current_price < last_buy_price && self.order_smarts.category_buy.where(status: [:status_created, :status_trading]).blank?
  end

  def should_sell_price
    traded_order_smarts = self.order_smarts.category_buy.status_traded
    (traded_order_smarts.sum(:total_price) / traded_order_smarts.sum(:real_amount) * self.sell_percent * 0.01).floor(trade_symbol.price_precision)
  end

  def should_sell_amount
    self.order_smarts.category_buy.status_traded.sum(:resolve_amount)
  end

  def can_make_sell_order?
    self.order_smarts.category_sell.where(status: [:status_created, :status_trading, :status_traded]).blank?
  end
end
