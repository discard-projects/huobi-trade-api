class BalanceIntervalsEachJob < ApplicationJob
  queue_as :default

  def perform(id)
    # Do something later
    balance_interval = BalanceInterval.find(id)
    balance_interval.with_lock do
      if balance_interval.order_intervals.where(status: [:status_created, :status_trading, :status_traded]).blank?
        user = balance_interval.user
        huobi_api = user.huobi_api
        trade_symbol = balance_interval.trade_symbol
        if huobi_api
          # buy_price = [trade_symbol.current_price, balance_interval.buy_price].min.floor(trade_symbol.price_precision)
          buy_price = balance_interval.buy_price.floor(trade_symbol.price_precision)
          order_interval = balance_interval.order_intervals.create(price: buy_price, amount: balance_interval.amount, category: 'category_buy')
          if order_interval.may_status_trading?
            order_interval.status_trading! rescue nil
          end
        end
      elsif balance_interval.order_intervals.where(status: [:status_trading, :status_traded]).blank?
        balance_interval.order_intervals.category_buy.status_created.each do |order_interval|
          if order_interval.may_status_trading?
            order_interval.status_trading! rescue nil
          end
        end
      end
    end
  end
end
