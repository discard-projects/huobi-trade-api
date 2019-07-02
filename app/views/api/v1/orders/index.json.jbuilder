json.partial! 'partial/paginate_meta', object: @orders
json.items @orders do |order|
  json.(order, :id, :hid, :symbol, :kind, :category, :status, :htype, :hstate, :amount, :price, :field_amount, :field_cash_amount, :field_fees, :hcreate_time, :hcancel_time, :hfinish_time, :created_time, :updated_time)
  json.symbol_base_currency order.trade_symbol.try(:base_currency)
  json.symbol_quote_currency order.trade_symbol.try(:quote_currency)
  json.symbol_current_price order.trade_symbol.try(:current_price)

  json.children order.children.order(updated_at: :desc) do |order|
    json.(order, :id, :hid, :symbol, :kind, :category, :status, :htype, :hstate, :amount, :price, :field_amount, :field_cash_amount, :field_fees, :hcreate_time, :hcancel_time, :hfinish_time, :created_time, :updated_time)
    json.symbol_base_currency order.trade_symbol.try(:base_currency)
    json.symbol_quote_currency order.trade_symbol.try(:quote_currency)
    json.symbol_current_price order.trade_symbol.try(:current_price)
  end
end