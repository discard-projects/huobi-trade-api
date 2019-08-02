class CreateTradeSymbolHistories < ActiveRecord::Migration[6.0]
  def change
    create_table :trade_symbol_histories do |t|
      t.references :trade_symbol, null: false, foreign_key: true

      t.decimal :amount, precision: 20, scale: 10, comment: "24小时成交量"
      t.decimal :count, precision: 20, scale: 10, comment: "24小时交易次数"
      t.decimal :open, precision: 20, scale: 10, comment: "阶段开盘价"
      t.decimal :close, precision: 20, scale: 10, comment: "阶段收盘价"
      t.decimal :high, precision: 20, scale: 10, comment: "阶段最高价"
      t.decimal :low, precision: 20, scale: 10, comment: "阶段最低价"

      t.decimal :previous_close, precision: 20, scale: 10, defaut: 0, comment: "阶段上一次收盘价"

      t.decimal :moment_rate, precision: 10, scale: 3, defaut: 0, comment: "比上一次增长比率"

      t.timestamps
    end
  end
end
