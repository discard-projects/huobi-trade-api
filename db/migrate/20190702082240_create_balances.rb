class CreateBalances < ActiveRecord::Migration[6.0]
  def change
    create_table :balances do |t|
      t.references :account, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :currency
      t.decimal :trade_balance, precision: 20, scale: 10, default: 0
      t.decimal :frozen_balance, precision: 20, scale: 10, default: 0

      t.timestamps
    end
  end
end
