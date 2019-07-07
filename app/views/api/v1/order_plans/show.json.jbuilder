json.item do
  json.(@order_plan, :id, :buy_price, :should_buy_price, :buy_amount, :sell_price, :sell_amount, :category, :status, :created_time, :updated_time)
  json.order @order_plan.order
end