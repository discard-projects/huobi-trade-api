class BalanceInterval < ApplicationRecord
  belongs_to :balance
  belongs_to :trade_symbol
  has_many :order_intervals, dependent: :destroy
  has_many :orders, as: :balancable, dependent: :nullify

  def user
    balance.user
  end
end
