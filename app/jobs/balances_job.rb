class BalancesJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Do something later
    # balance_intervals
    BalanceInterval.where(enabled: true).each do |balance_interval|
      BalanceIntervalsEachJob.perform_later(balance_interval.id)
    end
    # balance_smarts
    BalanceSmart.where(enabled: true).each do |balance_smart|
      BalanceSmartsEachJob.perform_later(balance_smart.id)
    end
    # balance_plans
    BalancePlan.where(enabled: true).each do |balance_plan|
      BalancePlansEachJob.perform_later(balance_plan.id)
    end
    BalancesJob.set(wait: 0.01.second).perform_later()
  end
end
