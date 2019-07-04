json.partial! 'partial/paginate_meta', object: @trade_symbols
json.items @trade_symbols do |trade_symbol|
  json.(trade_symbol, :id, :base_currency, :quote_currency, :current_price, :symbol_partition, :symbol, :enabled, :count, :open, :close, :high, :low, :created_time, :updated_time)
  json.include_users trade_symbol.users.map(&:email)
  # json.is_manager @is_manager
end