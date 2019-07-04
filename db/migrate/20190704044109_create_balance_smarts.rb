class CreateBalanceSmarts < ActiveRecord::Migration[6.0]
  def change
    create_table :balance_smarts do |t|
      t.references :balance, null: false, foreign_key: true
      t.references :trade_symbol, null: false, foreign_key: true
      t.decimal :open_price, precision: 20, scale: 10, comment: "起点下单价格"
      t.decimal :buy_percent, precision: 20, scale: 10, default: 0, comment: "起点下跌百分比买入"
      t.decimal :sell_percent, precision: 20, scale: 10, comment: "起点上涨百分比卖出"
      t.decimal :amount, precision: 20, scale: 10, default: 0
      t.decimal :rate_amount, precision: 20, scale: 10, default: 1
      t.decimal :max_amount, precision: 20, scale: 10, default: 999999999
      t.boolean :enabled, default: false

      t.timestamps
    end
  end
end
