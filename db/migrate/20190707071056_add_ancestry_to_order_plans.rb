class AddAncestryToOrderPlans < ActiveRecord::Migration[6.0]
  def change
    add_column :order_plans, :ancestry, :string
    add_index :order_plans, :ancestry
  end
end
