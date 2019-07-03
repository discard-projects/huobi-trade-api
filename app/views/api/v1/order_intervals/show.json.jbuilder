json.item do
  json.(@order_interval, :id, :price, :amount, :category, :status, :order, :created_time, :updated_time)

  json.children @order_interval.children
end