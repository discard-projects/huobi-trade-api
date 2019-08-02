class TradeSymbolsPriceFetchJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Do something later
    TradeSymbol.where(enabled: true).find_each do |trade_symbol|
      TradeSymbolPriceFetchJob.perform_later(trade_symbol.id)
    end

    if Time.current.hour == 0
      TradeSymbol.where(enabled: false).find_each do |trade_symbol|
        TradeSymbolPriceFetchJob.perform_later(trade_symbol.id)
      end
    end

    TradeSymbolsPriceFetchJob.set(wait: 1.second).perform_later()
  end
end
