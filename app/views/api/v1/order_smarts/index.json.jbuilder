json.partial! 'partial/paginate_meta', object: @order_smarts
json.items @order_smarts do |order_smart|
  json.(order_smart, :id, :price, :amount, :resolve_amount, :total_price, :status, :category, :created_time, :updated_time)
  json.full_coin_name "#{order_smart.balance_smart.trade_symbol.try(:base_currency).try(:upcase)} / #{order_smart.balance_smart.trade_symbol.try(:quote_currency).try(:upcase)}" rescue nil
  json.order order_smart.order
end