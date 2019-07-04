json.partial! 'partial/paginate_meta', object: @balance_smarts
json.items @balance_smarts do |balance_smart|
  json.(balance_smart, :id, :balance_id, :trade_symbol_id, :open_price, :amount, :rate_amount, :max_amount, :buy_percent, :sell_percent, :enabled,  :created_time, :updated_time)
  json.full_coin_name "#{balance_smart.trade_symbol.try(:base_currency).try(:upcase)} / #{balance_smart.trade_symbol.try(:quote_currency).try(:upcase)} [count: #{balance_smart.amount}]" rescue nil
  json.trade_symbol balance_smart.trade_symbol
end