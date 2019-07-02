class CreateOrders < ActiveRecord::Migration[6.0]
  def change
    create_table :orders do |t|
      t.integer :hid, limit: 8
      t.integer :kind, limit: 1
      t.decimal :amount, precision: 20, scale: 10
      t.decimal :price, precision: 20, scale: 10
      t.string :source, comment: "api下单该值为 api"
      t.string :hstate, comment: "订单状态	: submitting , submitted 已提交, partial-filled 部分成交, partial-canceled 部分成交撤销, filled 完全成交, canceled 已撤销"
      t.integer :status, limit: 1
      t.string :symbol
      t.string :htype, comment: "订单类型: submit-cancel：已提交撤单申请 ,buy-market：市价买, sell-market：市价卖, buy-limit：限价买, sell-limit：限价卖, buy-ioc：IOC买单, sell-ioc：IOC卖单"
      t.integer :category, limit: 1
      t.references :user, null: false, index: true, foreign_key: true
      t.references :account, null: false, foreign_key: true
      t.references :trade_symbol, null: false, foreign_key: true
      t.datetime :hcancel_at
      t.datetime :hcreate_at
      t.decimal :field_amount, precision: 20, scale: 10, comment: "已成交数量"
      t.decimal :field_cash_amount, precision: 20, scale: 10, comment: "已成交总金额"
      t.decimal :field_fees, precision: 20, scale: 10, comment: "已成交手续费（买入为基础币，卖出为计价币）"
      t.decimal :field_profit, precision: 20, scale: 10, comment: '已成交利润', default: 0
      t.datetime :hfinish_at

      t.references :balancable, polymorphic: true
      t.references :tradable, polymorphic: true

      t.timestamps
    end
  end
end
