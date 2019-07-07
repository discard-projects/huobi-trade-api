json.partial! 'partial/paginate_meta', object: @balance_plans
json.items @balance_plans do |balance_plan|
  json.(balance_plan, :id, :balance_id, :trade_symbol_id, :begin_price, :end_price, :interval_price, :open_price, :amount, :enabled, :addition_amount, :created_time, :updated_time)
  json.full_coin_name "#{balance_plan.trade_symbol.try(:base_currency).try(:upcase)} / #{balance_plan.trade_symbol.try(:quote_currency).try(:upcase)} [count: #{balance_plan.count}]" rescue nil
  json.trade_symbol balance_plan.trade_symbol
end