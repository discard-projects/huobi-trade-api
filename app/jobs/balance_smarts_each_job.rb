class BalanceSmartsEachJob < ApplicationJob
  queue_as :default

  def perform(id)
    # Do something later
    balance_smart = BalanceSmart.find(id)
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
