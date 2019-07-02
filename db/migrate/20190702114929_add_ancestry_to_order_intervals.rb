class AddAncestryToOrderIntervals < ActiveRecord::Migration[6.0]
  def change
    add_column :order_intervals, :ancestry, :string
    add_index :order_intervals, :ancestry
  end
end
