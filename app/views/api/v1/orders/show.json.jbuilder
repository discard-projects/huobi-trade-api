json.item do
  json.dynamic_current_price @order.trade_symbol.current_price rescue nil
  json.dynamic_profit_percent "#{(@order.trade_symbol.current_price -  @order.price) / @order.price * 100}%" rescue nil
  json.(@order, :id, :hid, :symbol, :htype, :kind, :hstate, :status, :amount, :price, :field_amount, :field_cash_amount, :field_fees, :hcreate_time, :hcancel_time, :hfinish_time, :created_time, :updated_time, :trade_symbol, :balancable, :tradable, :parent)
end