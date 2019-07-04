class CreateOrderSmarts < ActiveRecord::Migration[6.0]
  def change
    create_table :order_smarts do |t|
      t.references :balance_smart, null: false, foreign_key: true
      t.decimal :price, precision: 20, scale: 10
      t.decimal :amount, precision: 20, scale: 10, default: 0
      t.decimal :resolve_amount, precision: 20, scale: 10, default: 0
      t.decimal :total_price, precision: 20, scale: 10, default: 0
      t.integer :category, limit: 1
      t.integer :status, limit: 1

      t.timestamps
    end
  end
end
