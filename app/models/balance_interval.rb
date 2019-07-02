class BalanceInterval < ApplicationRecord
  belongs_to :balance
  belongs_to :trade_symbol
  has_many :order_intervals
  has_many :orders, as: :balancable

  def user
    balance.user
  end
end
