class Order < ApplicationRecord
  include AASM
  has_ancestry

  belongs_to :user
  belongs_to :account
  belongs_to :trade_symbol
  belongs_to :triggerable, polymorphic: true, optional: true

  # app购买 系统自动买入 定义价格买入卖出
  enum kind: { kind_app: 0, kind_auto: 1, kind_custom_price: 2, kind_plan: 3, kind_smart: 4 }
  ransacker :kind, formatter: proc { |v| kinds[v] }

  # category buy/sell
  enum category: { category_buy: 0, category_sell: 1 }
  ransacker :category, formatter: proc { |v| categories[v] }

  # status
  enum status: { status_created: 0, status_partial_filled: 1, status_filled: 2, status_finished: 3, status_canceled: 4 }
  ransacker :status, formatter: proc { |v| statuses[v] }

  aasm :column => :status, :enum => true do
    state :status_created, :initial => true
    state :status_partial_filled, :status_filled, :status_finished, :status_canceled
    event :status_partial_filled do
      transitions :from => :status_created, :to => :status_partial_filled
    end
    event :status_filled do
      transitions :from => [:status_created, :status_partial_filled], :to => :status_filled
    end
    event :status_finished do
      transitions :from => [:status_filled], :to => :status_finished
    end
    event :status_canceled do
      transitions :from => :status_created, :to => :status_canceled
    end
  end

end
