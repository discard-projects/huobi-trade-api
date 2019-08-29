class OrdersFetchJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Do something later
    User.find_each do |user|
      next unless user.trade_enabled

      TradeSymbol.where(enabled: true).find_each do |trade_symbol|
        if trade_symbol.users.include? user
          # 创建job获取 用户对应 trade_symbol的订单
          Rails.cache.fetch("OrdersFetchJob:Include:#{trade_symbol.id}:User#{user.id}", expires_in: 1.second) do
            OrdersUserTradeSymbolFetchJob.perform_later(user.id, trade_symbol.id)
          end
        else
          # 用户没有包含在trade_symbol的话每隔15分钟拉取一次
          Rails.cache.fetch("OrdersFetchJob:Exclude:#{trade_symbol.id}:User#{user.id}", expires_in: 15.minutes) do
            # 创建job获取 用户对应 trade_symbol的订单
            OrdersUserTradeSymbolFetchJob.perform_later(user.id, trade_symbol.id)
          end
        end
      end

      # 1小时
      Rails.cache.fetch("OrdersFetchJob:BeforeDate:#{trade_symbol.id}", expires_in: 1.hour) do
        user.orders.status_created.where('created_at < ?', Time.now - 24.hours).group(:trade_symbol_id).select(:trade_symbol_id).each do |o|
          order = user.orders.status_created.where(trade_symbol_id: o.trade_symbol_id).first
          if order && order.try(:hid)
            OrdersUserTradeSymbolFetchJob.perform_later(user.id, o.trade_symbol_id, order.created_at.strftime('%Y-%m-%d'))
          end
        end
      end
    end
    # sleep 1
    # OrdersFetchJob.perform_later()
    # OrdersFetchJob.set(wait: 5.second).perform_later()
    OrdersFetchJob.perform_later()
  end
end
