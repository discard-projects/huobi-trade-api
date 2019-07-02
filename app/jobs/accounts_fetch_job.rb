class AccountsFetchJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Do something later
    User.all.find_each do |user|
      if user.huobi_api.present?
        p user.email
        huobi_api = user.huobi_api
        data = huobi_api.accounts
        # p data
        data['data'] && data['data'].each do |acc|
          Account.find_or_create_by(hid: acc['id'], user: user) do |account|
            account.htype = acc['type']
            account.hsubtype = acc['subtype']
            account.hstate = acc['state']
          end
        end
      end
    end
  end
end
