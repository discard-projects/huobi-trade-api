json.partial! 'partial/paginate_meta', object: @balances
json.items @balances do |balance|
  json.(balance, :id, :currency, :frozen_balance, :trade_balance, :created_time, :updated_time)
  json.total_balance balance.frozen_balance + balance.trade_balance
  json.account_type balance.account.try(:ctype)

  json.balance_intervals balance.balance_intervals do |balance_interval|
    json.balance_interval balance_interval
    json.trade_symbol balance_interval.trade_symbol
  end

  json.enabled_items do
    json.固定值交易  balance.balance_intervals do |balance_interval|
      json.(balance_interval, :buy_price, :sell_price, :amount, :enabled)
    end
    json.计划交易 []
    json.智能交易 []
    # json.计划交易  balance.balance_plans do |balance_plan|
    #   json.(balance_plan, :range_begin_price, :interval_price, :count, :enabled)
    # end
    # json.智能交易  balance.balance_smarts do |balance_smart|
    #   json.(balance_smart, :sell_percent, :enabled)
    #   json.sell_percent "#{balance_smart.sell_percent}%"
    #   buyed_count = balance_smart.order_smarts.category_buy.where(status: [:status_traded]).sum(:count)
    #   last_price = balance_smart.order_smarts.category_buy.where(status: [:status_traded]).last.price rescue nil
    #   next_price = last_price - balance_smart.interval_price rescue nil
    #   avg_price = balance_smart.avg_price
    #   json.buyed_count buyed_count
    #   json.next_buy_percent "#{(balance_smart.interval_price / last_price * 100).floor(2)}%" rescue nil
    #   json.next_buy_price "#{next_price} = #{last_price} - #{balance_smart.interval_price}" rescue nil
    #   json.avg_price avg_price rescue nil
    #   json.calc_sell_price "#{balance_smart.sell_price} = #{avg_price} + #{avg_price * (balance_smart.sell_percent / 100)}" rescue nil
    #   mao_price = (avg_price * balance_smart.sell_percent * 0.01) * balance_smart.order_smarts.category_buy.status_traded.sum(:count) rescue nil
    #   fees_price = balance_smart.order_smarts.category_buy.status_traded.sum(:total_price) * 0.005 rescue nil
    #   json.profit "约#{balance_smart.trade_symbol.base_currency}:#{(mao_price-fees_price).floor(10)}=#{mao_price.floor(10)}-#{fees_price.floor(10)}" rescue nil
    # end
  end
end