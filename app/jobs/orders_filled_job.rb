class OrdersFilledJob < ApplicationJob
  queue_as :default

  def perform(*args)
    Order.status_created.where('created_at < ?', Time.now - 24.hours).where.not(hid: nil).group(:trade_symbol_id).select(:trade_symbol_id).each do |o|
      user = o.user
      trade_symbol = o.trade_symbol
      huobi_api = user.huobi_api
      if huobi_api
        data = huobi_api.history_matchresults trade_symbol.symbol
        data && data['data'] && data['data'].each do |o|
          order = Order.find_by(hid: o['order-id'])
          if order
            order.update(field_amount: o['filled-amount'], field_fees: o['filled-fees'])
            order.status_filled! if order.may_status_filled?
          end
        end
      end
    end
  end
  OrdersFilledJob.set(wait: 35.minutes).perform_later()
end
