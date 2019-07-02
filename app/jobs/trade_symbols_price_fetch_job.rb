class TradeSymbolsPriceFetchJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Do something later
    TradeSymbol.where(enabled: true).find_each do |trade_symbol|
      TradeSymbolPriceFetchJob.perform_later(trade_symbol.id)
    end
    TradeSymbolsPriceFetchJob.set(wait: 1.second).perform_later()
  end
end
