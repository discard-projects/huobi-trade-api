class OrdersFetchJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Do something later
    User.find_each do |user|
      next unless user.trade_enabled

      TradeSymbol.where(enabled: true).find_each do |trade_symbol|
        if trade_symbol.users.include? user
          # 创建job获取 用户对应 trade_symbol的订单
          OrdersUserTradeSymbolFetchJob.perform_later(user.id, trade_symbol.id)
        end
      end
    end
    OrdersFetchJob.set(wait: 1.second).perform_later()
  end
end
