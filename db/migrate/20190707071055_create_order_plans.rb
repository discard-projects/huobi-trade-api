class CreateOrderPlans < ActiveRecord::Migration[6.0]
  def change
    create_table :order_plans do |t|
      t.references :balance_plan, null: false, foreign_key: true
      t.decimal :buy_price, precision: 20, scale: 10, default: 0, comment: '记号买入价'
      t.decimal :should_buy_price, precision: 20, scale: 10, default: 0, comment: '真实下单参考价格'
      t.decimal :buy_amount, precision: 20, scale: 10, default: 0
      t.decimal :sell_price, precision: 20, scale: 10, default: 0, comment: '记号卖出价'
      t.decimal :sell_amount, precision: 20, scale: 10, default: 0
      t.integer :category, limit: 1
      t.integer :status, limit: 1
      t.timestamps
    end
  end
end
