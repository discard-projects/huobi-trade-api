class Balance < ApplicationRecord
  belongs_to :user
  belongs_to :account
  has_many :balance_intervals
end