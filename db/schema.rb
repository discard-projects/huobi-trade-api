# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_08_02_021232) do

  create_table "accounts", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "hid"
    t.string "htype"
    t.string "hsubtype"
    t.string "hstate"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_accounts_on_user_id"
  end

  create_table "balance_intervals", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "balance_id", null: false
    t.bigint "trade_symbol_id", null: false
    t.decimal "buy_price", precision: 20, scale: 10, default: "0.0"
    t.decimal "sell_price", precision: 20, scale: 10, default: "0.0"
    t.decimal "amount", precision: 20, scale: 10, default: "0.0"
    t.boolean "enabled", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "custom_sell_enabled", default: false, comment: "是否手动卖出"
    t.index ["balance_id"], name: "index_balance_intervals_on_balance_id"
    t.index ["trade_symbol_id"], name: "index_balance_intervals_on_trade_symbol_id"
  end

  create_table "balance_plans", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "balance_id", null: false
    t.bigint "trade_symbol_id", null: false
    t.decimal "begin_price", precision: 20, scale: 10, default: "0.0"
    t.decimal "end_price", precision: 20, scale: 10, default: "0.0"
    t.decimal "interval_price", precision: 20, scale: 10, default: "0.0"
    t.decimal "open_price", precision: 20, scale: 10, default: "0.0"
    t.decimal "amount", precision: 20, scale: 10, default: "0.0"
    t.decimal "addition_amount", precision: 20, scale: 10, default: "0.0"
    t.boolean "enabled", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["balance_id"], name: "index_balance_plans_on_balance_id"
    t.index ["trade_symbol_id"], name: "index_balance_plans_on_trade_symbol_id"
  end

  create_table "balance_smarts", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "balance_id", null: false
    t.bigint "trade_symbol_id", null: false
    t.decimal "open_price", precision: 20, scale: 10, comment: "起点下单价格"
    t.decimal "buy_percent", precision: 20, scale: 10, default: "0.0", comment: "起点下跌百分比买入"
    t.decimal "sell_percent", precision: 20, scale: 10, comment: "起点上涨百分比卖出"
    t.decimal "amount", precision: 20, scale: 10, default: "0.0"
    t.decimal "rate_amount", precision: 20, scale: 10, default: "1.0"
    t.decimal "max_amount", precision: 20, scale: 10, default: "999999999.0"
    t.boolean "enabled", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["balance_id"], name: "index_balance_smarts_on_balance_id"
    t.index ["trade_symbol_id"], name: "index_balance_smarts_on_trade_symbol_id"
  end

  create_table "balances", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.bigint "user_id", null: false
    t.string "currency"
    t.decimal "trade_balance", precision: 20, scale: 10, default: "0.0"
    t.decimal "frozen_balance", precision: 20, scale: 10, default: "0.0"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["account_id"], name: "index_balances_on_account_id"
    t.index ["user_id"], name: "index_balances_on_user_id"
  end

  create_table "order_intervals", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "balance_interval_id", null: false
    t.decimal "price", precision: 20, scale: 10
    t.decimal "amount", precision: 20, scale: 10
    t.integer "category", limit: 1
    t.integer "status", limit: 1
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "ancestry"
    t.index ["ancestry"], name: "index_order_intervals_on_ancestry"
    t.index ["balance_interval_id"], name: "index_order_intervals_on_balance_interval_id"
  end

  create_table "order_plans", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "balance_plan_id", null: false
    t.decimal "buy_price", precision: 20, scale: 10, default: "0.0"
    t.decimal "should_buy_price", precision: 20, scale: 10, default: "0.0", comment: "真实下单参考价格"
    t.decimal "buy_amount", precision: 20, scale: 10, default: "0.0"
    t.decimal "sell_price", precision: 20, scale: 10, default: "0.0"
    t.decimal "sell_amount", precision: 20, scale: 10, default: "0.0"
    t.integer "category", limit: 1
    t.integer "status", limit: 1
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "ancestry"
    t.index ["ancestry"], name: "index_order_plans_on_ancestry"
    t.index ["balance_plan_id"], name: "index_order_plans_on_balance_plan_id"
  end

  create_table "order_smarts", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "balance_smart_id", null: false
    t.decimal "price", precision: 20, scale: 10
    t.decimal "amount", precision: 20, scale: 10, default: "0.0"
    t.decimal "resolve_amount", precision: 20, scale: 10, default: "0.0"
    t.decimal "total_price", precision: 20, scale: 10, default: "0.0"
    t.integer "category", limit: 1
    t.integer "status", limit: 1
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["balance_smart_id"], name: "index_order_smarts_on_balance_smart_id"
  end

  create_table "orders", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "hid"
    t.integer "kind", limit: 1
    t.decimal "amount", precision: 20, scale: 10
    t.decimal "price", precision: 20, scale: 10
    t.string "source", comment: "api下单该值为 api"
    t.string "hstate", comment: "订单状态\t: submitting , submitted 已提交, partial-filled 部分成交, partial-canceled 部分成交撤销, filled 完全成交, canceled 已撤销"
    t.integer "status", limit: 1
    t.string "symbol"
    t.string "htype", comment: "订单类型: submit-cancel：已提交撤单申请 ,buy-market：市价买, sell-market：市价卖, buy-limit：限价买, sell-limit：限价卖, buy-ioc：IOC买单, sell-ioc：IOC卖单"
    t.integer "category", limit: 1
    t.bigint "user_id", null: false
    t.bigint "account_id", null: false
    t.bigint "trade_symbol_id", null: false
    t.datetime "hcancel_at"
    t.datetime "hcreate_at"
    t.decimal "field_amount", precision: 20, scale: 10, comment: "已成交数量"
    t.decimal "field_cash_amount", precision: 20, scale: 10, comment: "已成交总金额"
    t.decimal "field_fees", precision: 20, scale: 10, comment: "已成交手续费（买入为基础币，卖出为计价币）"
    t.decimal "field_profit", precision: 20, scale: 10, default: "0.0", comment: "已成交利润"
    t.datetime "hfinish_at"
    t.string "balancable_type"
    t.bigint "balancable_id"
    t.string "tradable_type"
    t.bigint "tradable_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "ancestry"
    t.index ["account_id"], name: "index_orders_on_account_id"
    t.index ["ancestry"], name: "index_orders_on_ancestry"
    t.index ["balancable_type", "balancable_id"], name: "index_orders_on_balancable_type_and_balancable_id"
    t.index ["tradable_type", "tradable_id"], name: "index_orders_on_tradable_type_and_tradable_id"
    t.index ["trade_symbol_id"], name: "index_orders_on_trade_symbol_id"
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "trade_symbol_histories", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "trade_symbol_id", null: false
    t.decimal "amount", precision: 20, scale: 10, comment: "24小时成交量"
    t.decimal "count", precision: 20, scale: 10, comment: "24小时交易次数"
    t.decimal "open", precision: 20, scale: 10, comment: "阶段开盘价"
    t.decimal "close", precision: 20, scale: 10, comment: "阶段收盘价"
    t.decimal "high", precision: 20, scale: 10, comment: "阶段最高价"
    t.decimal "low", precision: 20, scale: 10, comment: "阶段最低价"
    t.decimal "previous_close", precision: 20, scale: 10, comment: "阶段上一次收盘价"
    t.decimal "moment_rate", precision: 10, scale: 3, comment: "比上一次增长比率"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["trade_symbol_id"], name: "index_trade_symbol_histories_on_trade_symbol_id"
  end

  create_table "trade_symbols", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "base_currency"
    t.string "quote_currency"
    t.integer "price_precision", default: 0
    t.integer "amount_precision", default: 0
    t.string "symbol_partition"
    t.string "symbol"
    t.boolean "enabled", default: false
    t.decimal "amount", precision: 20, scale: 10, comment: "24小时成交量"
    t.decimal "count", precision: 20, scale: 10, comment: "24小时交易次数"
    t.decimal "open", precision: 20, scale: 10, comment: "阶段开盘价"
    t.decimal "close", precision: 20, scale: 10, comment: "阶段收盘价"
    t.decimal "high", precision: 20, scale: 10, comment: "阶段最高价"
    t.decimal "low", precision: 20, scale: 10, comment: "阶段最低价"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "provider", default: "email", null: false
    t.string "uid", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.boolean "allow_password_change", default: false
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.string "name"
    t.string "nickname"
    t.string "image"
    t.string "email"
    t.text "huobi"
    t.text "tokens"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["uid", "provider"], name: "index_users_on_uid_and_provider", unique: true
  end

  add_foreign_key "accounts", "users"
  add_foreign_key "balance_intervals", "balances"
  add_foreign_key "balance_intervals", "trade_symbols"
  add_foreign_key "balance_plans", "balances"
  add_foreign_key "balance_plans", "trade_symbols"
  add_foreign_key "balance_smarts", "balances"
  add_foreign_key "balance_smarts", "trade_symbols"
  add_foreign_key "balances", "accounts"
  add_foreign_key "balances", "users"
  add_foreign_key "order_intervals", "balance_intervals"
  add_foreign_key "order_plans", "balance_plans"
  add_foreign_key "order_smarts", "balance_smarts"
  add_foreign_key "orders", "accounts"
  add_foreign_key "orders", "trade_symbols"
  add_foreign_key "orders", "users"
  add_foreign_key "trade_symbol_histories", "trade_symbols"
end
