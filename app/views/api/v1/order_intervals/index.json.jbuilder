json.partial! 'partial/paginate_meta', object: @order_intervals
json.items @order_intervals do |order_interval|
  json.(order_interval, :id, :price, :amount, :category, :status,  :created_time, :updated_time)
  json.full_coin_name "#{order_interval.balance_interval.trade_symbol.try(:base_currency).try(:upcase)} / #{order_interval.balance_interval.trade_symbol.try(:quote_currency).try(:upcase)}" rescue nil
  json.order order_interval.order

  json.children do |order_interval|
    json.(order_interval, :id, :price, :amount, :category, :status,  :created_time, :updated_time)
    json.full_coin_name "#{order_interval.balance_interval.trade_symbol.try(:base_currency).try(:upcase)} / #{order_interval.balance_interval.trade_symbol.try(:quote_currency).try(:upcase)}" rescue nil
    json.order order_interval.order
  end
end