class Balance < ApplicationRecord
  belongs_to :user
  belongs_to :account
  has_many :balance_intervals
  has_many :balance_smarts
  has_many :balance_plans
end
