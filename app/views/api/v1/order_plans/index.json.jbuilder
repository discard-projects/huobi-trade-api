json.partial! 'partial/paginate_meta', object: @order_plans
json.items @order_plans do |order_plan|
  json.(order_plan, :id, :buy_price, :should_buy_price, :buy_amount, :sell_price, :sell_amount, :category, :status, :created_time, :updated_time)
  json.full_coin_name "#{order_plan.balance_plan.trade_symbol.try(:base_currency).try(:upcase)} / #{order_plan.balance_plan.trade_symbol.try(:quote_currency).try(:upcase)}" rescue nil
  json.order order_plan.order

  json.children order_plan.children do |order_plan|
    json.(order_plan, :id, :buy_price, :should_buy_price, :buy_amount, :sell_price, :sell_amount, :category, :status, :created_time, :updated_time)
    json.full_coin_name "#{order_plan.balance_plan.trade_symbol.try(:base_currency).try(:upcase)} / #{order_plan.balance_plan.trade_symbol.try(:quote_currency).try(:upcase)}" rescue nil
    json.order order_plan.order
  end
end