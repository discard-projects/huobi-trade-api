class BalancePlan < ApplicationRecord
  belongs_to :balance
  belongs_to :trade_symbol
  has_many :order_plans

  def user
    balance.user
  end

  def next_should_buy_price
    trade_symbol.current_price - (trade_symbol.current_price - self.open_price) % self.interval_price
  end

  def next_should_buy_amount
    should_buy_price = next_should_buy_price
    (self.amount - (should_buy_price - self.open_price) / self.interval_price * self.addition_amount).floor(trade_symbol.amount_precision)
  end
end
