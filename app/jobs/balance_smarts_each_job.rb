class BalanceSmartsEachJob < ApplicationJob
  queue_as :default

  def perform(id)
    # Do something later
    balance_smart = BalanceSmart.find(id)
    # 通知
    balance_smart_current_price = balance_smart.trade_symbol.current_price
    if balance_smart_current_price > balance_smart.avg_price
      Rails.cache.fetch("BalanceSmartsEachJob:BalanceSmart:Win:#{balance_smart.id}", expires_in: 15.seconds) do
        user.slack_notifier&.ping "-- #{balance_smart.trade_symbol.symbol} current win #{((balance_smart_current_price - balance_smart.avg_price) / balance_smart.avg_price).round(5) * 100}%", {icon_emoji: ':point_right:', mrkdwn: true} rescue nil
      end
    end

    # 下单
    balance_smart.with_lock do
      user = balance_smart.user
      huobi_api = user.huobi_api
      if huobi_api && balance_smart.can_make_buy_order?
        # 取消准备卖出的订单
        balance_smart.order_smarts.category_sell.status_trading.each do |selling_order_smart|
          selling_order_smart.try_cancel!
        end
        buy_price = balance_smart.next_should_buy_price
        buy_amount = balance_smart.next_should_buy_amount
        order_smart = balance_smart.order_smarts.create(price: buy_price, amount: buy_amount, category: 'category_buy')
        order_smart.status_trading! if order_smart.may_status_trading?
      elsif huobi_api && balance_smart.can_make_sell_order?
        balance_smart.order_smarts.category_buy.where(status: [:status_created, :status_trading]).each do |buying_order_smart|
          buying_order_smart.try_cancel!
        end
        sell_price = balance_smart.should_sell_price
        sell_amount =balance_smart.should_sell_amount
        sell_order_smart = balance_smart.order_smarts.create(price: sell_price, amount: sell_amount, category: 'category_sell')
        if sell_order_smart.may_status_trading?
          sell_order_smart.status_trading!
        end
      end
    end
  end
end
