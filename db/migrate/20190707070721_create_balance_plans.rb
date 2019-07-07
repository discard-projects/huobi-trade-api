class CreateBalancePlans < ActiveRecord::Migration[6.0]
  def change
    create_table :balance_plans do |t|
      t.references :balance, null: false, foreign_key: true
      t.references :trade_symbol, null: false, foreign_key: true
      t.decimal :begin_price, precision: 20, scale: 10, default: 0
      t.decimal :end_price, precision: 20, scale: 10, default: 0
      t.decimal :interval_price, precision: 20, scale: 10, default: 0
      t.decimal :open_price, precision: 20, scale: 10, default: 0
      t.decimal :amount, precision: 20, scale: 10, default: 0
      t.decimal :addition_amount, precision: 20, scale: 10, default: 0
      t.boolean :enabled, default: false

      t.timestamps
    end
  end
end
