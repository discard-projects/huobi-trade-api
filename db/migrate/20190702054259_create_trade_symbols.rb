class CreateTradeSymbols < ActiveRecord::Migration[6.0]
  def change
    create_table :trade_symbols do |t|
      t.string :base_currency
      t.string :quote_currency
      t.integer :price_precision, default: 0
      t.integer :amount_precision, default: 0
      t.string :symbol_partition
      t.string :symbol

      t.boolean :enabled, default: false

      t.decimal :amount, precision: 20, scale: 10, comment: "24小时成交量"
      t.decimal :count, precision: 20, scale: 10, comment: "24小时交易次数"
      t.decimal :open, precision: 20, scale: 10, comment: "阶段开盘价"
      t.decimal :close, precision: 20, scale: 10, comment: "阶段收盘价"
      t.decimal :high, precision: 20, scale: 10, comment: "阶段最高价"
      t.decimal :low, precision: 20, scale: 10, comment: "阶段最低价"

      t.timestamps
    end
  end
end
