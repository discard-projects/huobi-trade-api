class BalancesFetchJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Do something later
    User.find_each do |user|
      next unless user.trade_enabled
      huobi_api = user.huobi_api
      if huobi_api
        user.accounts.find_each do |account|
          data = huobi_api.balances(account.cid)
          # p account.cid, data
          data && data['data'] && data['data']['list'].each do |bal|
            balance = Balance.find_or_create_by(user: user, account: account, currency: bal['currency'])
            if bal['type'] == 'frozen'
              balance.update(frozen_balance: bal['balance'])
            elsif bal['type'] == 'trade'
              balance.update(trade_balance: bal['balance'])
            end
          end
        end
      end
    end
  end
end
