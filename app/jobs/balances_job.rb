class BalancesJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Do something later
    # balance_intervals
    BalanceInterval.where(enabled: true).each do |balance_interval|
      balance_interval.with_lock do
        if balance_interval.order_intervals.where(status: [:status_created, :status_trading, :status_traded]).blank?
          user = balance_interval.user
          huobi_api = user.huobi_api
          trade_symbol = balance_interval.trade_symbol
          if huobi_api
            buy_price = [trade_symbol.current_price, balance_interval.buy_price].min.floor(trade_symbol.price_precision)
            order_interval = balance_interval.order_intervals.create(price: buy_price, amount: balance_interval.amount, category: 'category_buy')
            order_interval.status_trading! if order_interval.may_status_trading?
          end
        end
      end
    end
    # balance_smarts
    BalanceSmart.where(enabled: true).each do |balance_smart|
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
    BalancesJob.set(wait: 1.second).perform_later()
  end
end
