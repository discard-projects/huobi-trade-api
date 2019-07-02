json.partial! 'partial/paginate_meta', object: @balance_intervals
json.items @balance_intervals do |balance_interval|
  json.(balance_interval, :id, :buy_price, :sell_price, :amount, :enabled, :created_time, :updated_time)
  json.trade_symbol do
    json.(balance_interval.trade_symbol, :id, :base_currency, :quote_currency)
  end
end