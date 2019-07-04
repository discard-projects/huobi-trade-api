json.item do
  json.(@order_smart, :id, :price, :amount, :resolve_amount, :total_price, :status, :category, :created_time, :order, :balance_smart, :updated_time)
  json.full_coin_name "#{@order_smart.balance_smart.trade_symbol.try(:base_currency).try(:upcase)} / #{@order_smart.balance_smart.trade_symbol.try(:quote_currency).try(:upcase)}" rescue nil
end