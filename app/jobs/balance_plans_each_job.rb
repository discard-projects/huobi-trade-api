class BalancePlansEachJob < ApplicationJob
  queue_as :default

  def perform(id)
    # Do something later
    balance_plan = BalancePlan.find(id)
    balance_plan.with_lock do
      user = balance_plan.user
      huobi_api = user.huobi_api
      if huobi_api
        # 以当前open_price购买比当前价格高的order_plan节点
        if balance_plan.order_plans.blank?
          self.balance_plan_buy_top_price_with_open_price balance_plan rescue nil
          # 保证第一次 将从起始价到顶价 间隔 已经全部买入
        elsif balance_plan.order_plans.category_buy.where(status: [:status_traded, :status_closed]).size >= balance_plan.init_should_buy_traded_size
          # 判断当前价格是否需要买入
          next_should_buy_price = balance_plan.next_should_buy_price
          next_should_buy_amount = balance_plan.next_should_buy_amount

          next if next_should_buy_price < balance_plan.begin_price || next_should_buy_price > balance_plan.end_price

          # 尝试将比next_should_buy_price小的正在交易的订单取消掉, 这里尝试取消未买入  间隔区间*0.9 防止在价格临界点频繁下单并取消
          balance_plan.order_plans.category_buy.where(status: [:status_created, :status_trading]).where('buy_price < ?', next_should_buy_price - balance_plan.interval_price * 0.9).each do |buying_order_plan|
            buying_order_plan.try_cancel!
          end
          if balance_plan.order_plans.category_buy.where(status: [:status_created, :status_trading, :status_traded]).where('buy_price <= ?', next_should_buy_price).blank?
            order_plan = balance_plan.order_plans.create(buy_price: next_should_buy_price, should_buy_price: next_should_buy_price, buy_amount: next_should_buy_amount, sell_price: next_should_buy_price + balance_plan.interval_price, category: 'category_buy')
            if order_plan.may_status_trading?
              order_plan.status_trading!
            end
          end
        end
      end
    end
  end

  def balance_plan_buy_top_price_with_open_price balance_plan
    trade_symbol = balance_plan.trade_symbol
    (balance_plan.open_price..balance_plan.end_price).step(balance_plan.interval_price).each_with_index do |virtual_buy_price, index|
      calc_should_buy_price = [trade_symbol.current_price, balance_plan.open_price].min.floor(trade_symbol.price_precision)
      calc_should_sell_price = virtual_buy_price + balance_plan.interval_price
      little_minus_amount = 0.1 ** trade_symbol.amount_precision * index
      calc_should_buy_amount = (balance_plan.amount - little_minus_amount - (calc_should_buy_price - balance_plan.open_price) / balance_plan.interval_price * balance_plan.addition_amount).floor(trade_symbol.amount_precision)

      order_plan = balance_plan.order_plans.create(buy_price: virtual_buy_price, should_buy_price: calc_should_buy_price, buy_amount: calc_should_buy_amount, sell_price: calc_should_sell_price, category: 'category_buy')
      if order_plan.may_status_trading?
        order_plan.status_trading!
      end
    end
  end
end
