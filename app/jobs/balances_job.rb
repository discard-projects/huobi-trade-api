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
    # balance_plans
    BalancePlan.where(enabled: true).each do |balance_plan|
      balance_plan.with_lock do
        user = balance_plan.user
        huobi_api = user.huobi_api
        if huobi_api
          # 以当前open_price购买比当前价格高的order_plan节点
          if balance_plan.order_plans.blank?
            self.balance_plan_buy_top_price_with_open_price balance_plan rescue nil
          else
            # 判断当前价格是否需要买入
            next_should_buy_price = balance_plan.next_should_buy_price
            next_should_buy_amount = balance_plan.next_should_buy_amount

            # 尝试将比next_should_buy_price小的正在交易的订单取消掉
            balance_plan.order_plans.status_buyed.where(status: [:status_created, :status_trading]).where('buy_price < ?', next_should_buy_price).each do |buying_order_plan|
              buying_order_plan.try_cancel!
            end
            if balance_plan.order_plans.status_buyed.where(status: [:status_created, :status_trading, :status_traded]).where('buy_price <= ?', next_should_buy_price).blank?
              order_plan = balance_plan.order_plans.create(buy_price: next_should_buy_price, should_buy_price: next_should_buy_price, buy_amount: next_should_buy_amount, sell_price: next_should_buy_price + balance_plan.interval_price, category: 'category_buy')
              if order_plan.may_status_trading?
                order_plan.status_trading!
              end
            end
          end
        end
      end
    end
    BalancesJob.set(wait: 1.second).perform_later()
  end


  def balance_plan_buy_top_price_with_open_price balance_plan
    trade_symbol = balance_plan.trade_symbol
    (balance_plan.open_price..balance_plan.end_price).step(balance_plan.interval_price).each do |virtual_buy_price|
      calc_should_buy_price = [trade_symbol.current_price, balance_plan.open_price].min.floor(trade_symbol.price_precision)
      calc_should_sell_price = virtual_buy_price + balance_plan.interval_price
      calc_should_buy_amount = (balance_plan.amount - (calc_should_buy_price - balance_plan.open_price) / balance_plan.interval_price * balance_plan.addition_amount).floor(trade_symbol.amount_precision)

      order_plan = balance_plan.order_plans.create(buy_price: virtual_buy_price, should_buy_price: calc_should_buy_price, buy_amount: calc_should_buy_amount, sell_price: calc_should_sell_price, category: 'category_buy')
      if order_plan.may_status_trading?
        order_plan.status_trading!
      end
    end
  end
end
