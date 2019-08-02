class TradeSymbolsFetchJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Do something later
    data = Huobi.new.symbols['data']
    # p data
    data && data.each do |tb|
      should_send_new_trade_symbol_slack_notify = TradeSymbol.count > 0
      TradeSymbol.find_or_create_by(base_currency: tb['base-currency'], quote_currency: tb['quote-currency']) do |trade_symbol|
        trade_symbol.price_precision = tb['price-precision']
        trade_symbol.amount_precision = tb['amount-precision']
        trade_symbol.symbol_partition = tb['symbol-partition']
        trade_symbol.symbol = tb['symbol']
        if should_send_new_trade_symbol_slack_notify
          User.find_each do |user|
            user.slack_notifier&.ping "🚘 find new symbol #{trade_symbol.symbol}", {icon_emoji: ':warning:', mrkdwn: true} rescue nil
          end
        end
      end
    end

    # 删除之前的history
    TradeSymbolHistory.where('created_at <', Time.now - 10.minutes).destroy_all

    TradeSymbolsFetchJob.set(wait: 7.minute).perform_later()
  end
end
