class AddAncestryToOrders < ActiveRecord::Migration[6.0]
  def change
    add_column :orders, :ancestry, :string
    add_index :orders, :ancestry
  end
end
