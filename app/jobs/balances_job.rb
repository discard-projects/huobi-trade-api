class BalancesJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Do something later
    BalanceInterval.where(enabled: true).each do |balance_interval|
      balance_interval.with_lock do
        if balance_interval.order_intervals.where(status: [:status_created, :status_trading, :status_traded]).blank?
          user = balance_interval.user
          huobi_api = user.huobi_api
          trade_symbol = balance_interval.trade_symbol
          p "-------------------------- #{user.email}"
          if huobi_api
            buy_price = [trade_symbol.current_price, balance_interval.buy_price].min.floor(trade_symbol.price_precision)
            order_interval = balance_interval.order_intervals.create(price: buy_price, amount: balance_interval.amount, category: 'category_buy')
            order_interval.status_trading! if order_interval.may_status_trading?
          end
        end
      end
    end
    BalancesJob.set(wait: 1.second).perform_later()
  end
end
