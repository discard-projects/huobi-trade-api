json.partial! 'partial/paginate_meta', object: @balances
json.items @balances do |balance|
  json.(balance, :id, :currency, :frozen_balance, :trade_balance, :created_time, :updated_time)
  json.total_balance balance.frozen_balance + balance.trade_balance
  json.account_type balance.account.try(:ctype)

  json.balance_intervals balance.balance_intervals do |balance_interval|
    json.balance_interval balance_interval
    json.trade_symbol balance_interval.trade_symbol
  end

  json.balance_plans balance.balance_plans do |balance_plan|
    json.balance_plan balance_plan
    json.trade_symbol balance_plan.trade_symbol
  end

  json.balance_smarts balance.balance_smarts do |balance_smart|
    json.balance_smart balance_smart
    json.trade_symbol balance_smart.trade_symbol
  end

  json.enabled_items do
    json.固定值交易  balance.balance_intervals do |balance_interval|
      json.(balance_interval, :buy_price, :sell_price, :amount, :enabled)
    end
    json.计划交易  balance.balance_plans do |balance_plan|
      json.(balance_plan, :open_price, :interval_price, :amount, :addition_amount, :enabled)
    end
    json.智能交易 balance.balance_smarts do |balance_smart|
      json.(balance_smart, :amount, :open_price, :enabled, :resolve_amount, :next_should_buy_price, :next_should_buy_amount, :avg_price, :sell_percent, :should_sell_price, :should_sell_amount)
      json.calc_should_sell_price "#{balance_smart.should_sell_price} = #{balance_smart.avg_price} + #{balance_smart.avg_price * balance_smart.sell_percent * 0.01}"
    end
  end
end