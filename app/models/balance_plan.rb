class BalancePlan < ApplicationRecord
  belongs_to :balance
  belongs_to :trade_symbol
  has_many :order_plans, dependent: :destroy

  def user
    balance.user
  end

  def init_should_buy_traded_size
    (self.open_price..self.end_price).step(self.interval_price).size
  end

  def next_should_buy_price
    last_traded_buy_order = self.order_plans.category_buy.status_traded.order(buy_price: :asc).first
    if last_traded_buy_order
      last_traded_buy_order.buy_price - self.interval_price
    else
      trade_symbol.current_price - (trade_symbol.current_price - self.open_price) % self.interval_price
    end
  end

  def next_should_buy_amount
    should_buy_price = next_should_buy_price
    (self.amount - (should_buy_price - self.open_price) / self.interval_price * self.addition_amount).floor(trade_symbol.amount_precision)
  end
end
