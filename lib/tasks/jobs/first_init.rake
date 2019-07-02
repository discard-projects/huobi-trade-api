namespace :jobs do
  task first_init: :environment do
    AccountsFetchJob.perform_later()
    TradeSymbolsFetchJob.set(wait: 1.minute).perform_later()
    TradeSymbolsPriceFetchJob.perform_later()



    # 抓取平台的 成交订单 价格和数量
    # TradeRecordsWorker.perform_at(10.seconds.from_now)
    # 获取用户用户货币数 冻结数量/可交易数量
    # BalancesWorker.perform_at(30.seconds.from_now)
    # 抓取订单
    # OrdersWorker.perform_at(20.seconds.from_now)
    # 尝试下单
    # OrderCreateWorker.perform_at(5.seconds.from_now)
    # 计划下单
    # OrderPlanCreateWorker.perform_at(5.seconds.from_now)
    # 智能下单
    # OrderSmartCreateWorker.perform_at(10.seconds.from_now)
  end
end