class BalancesJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Do something later

    Rails.cache.fetch("BalancesJob:Intervals:Plans", expires_in: 1.seconds) do
      # balance_intervals
      BalanceInterval.where(enabled: true).each do |balance_interval|
        BalanceIntervalsEachJob.perform_later(balance_interval.id)
      end
      # balance_plans
      BalancePlan.where(enabled: true).each do |balance_plan|
        BalancePlansEachJob.perform_later(balance_plan.id)
      end
    end

    Rails.cache.fetch("BalancesJob:Smarts", expires_in: 30.seconds) do
      # balance_smarts
      BalanceSmart.where(enabled: true).each do |balance_smart|
        BalanceSmartsEachJob.perform_later(balance_smart.id)
      end
    end

    # BalancesJob.set(wait: 5.second).perform_later()
    BalancesJob.perform_later()
  end
end
