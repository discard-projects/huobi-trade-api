namespace :jobs do
  task first_init: :environment do
    # only once
    AccountsFetchJob.perform_later()
    # 15.minutes one time
    TradeSymbolsFetchJob.perform_later()
    # 越快越好
    TradeSymbolsPriceFetchJob.perform_later()
    # 10s一次
    BalancesFetchJob.perform_later()
    # 10s一次
    OrdersFetchJob.perform_later()
    # 35 minutes one time
    # OrdersFilledJob.perform_later()

    BalancesJob.perform_later()

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