json.item do
  json.(@balance, :id, :currency, :frozen_balance, :trade_balance, :created_time, :updated_time)

  # json.total_smart_real_buyed_count @balance.balance_smarts.inject(0) { |sum, child| sum + child.order_smarts.category_buy.where(status: [:status_traded]).sum(:real_count) }

  json.balance_intervals @balance.balance_intervals.order(trade_symbol_id: :desc, buy_price: :desc) do |balance_interval|
    json.(balance_interval, :id, :balance_id, :trade_symbol_id, :buy_price, :sell_price, :amount, :enabled)
    json.trade_symbol_base_currency balance_interval.trade_symbol.try(:base_currency)
    json.trade_symbol_quote_currency balance_interval.trade_symbol.try(:quote_currency)
  end

  json.balance_plans @balance.balance_plans do |balance_plan|
    json.(balance_plan, :id, :balance_id, :trade_symbol_id, :begin_price, :end_price, :interval_price, :open_price, :amount, :enabled, :addition_amount,  :created_time, :updated_time)
    json.trade_symbol do
      json.(balance_plan.trade_symbol, :id, :base_currency, :quote_currency)
    end
  end

  json.balance_smarts @balance.balance_smarts do |balance_smart|
    json.(balance_smart, :id, :open_price, :amount, :rate_amount, :max_amount, :buy_percent, :sell_percent, :enabled,  :created_time, :updated_time)
    json.trade_symbol do
      json.(balance_smart.trade_symbol, :id, :base_currency, :quote_currency)
    end
  end
end