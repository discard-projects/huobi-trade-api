class TradeSymbolsPriceFetchJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Do something later
    TradeSymbol.where(enabled: true).find_each do |trade_symbol|
      if trade_symbol.exist_enabled_config?
        Rails.cache.fetch("TradeSymbolsPriceFetchJob:ExistEnabledConfig", expires_in: 1.seconds) do
          TradeSymbolPriceFetchJob.perform_later(trade_symbol.id)
        end
      else
        Rails.cache.fetch("TradeSymbolsPriceFetchJob:NotExistEnabledConfig", expires_in: 45.seconds) do
          TradeSymbolPriceFetchJob.perform_later(trade_symbol.id)
        end
      end
    end

    # if Time.current.hour == 0
    #   TradeSymbol.where(enabled: false).find_each do |trade_symbol|
    #     TradeSymbolPriceFetchJob.perform_later(trade_symbol.id)
    #   end
    # end

    # TradeSymbolsPriceFetchJob.set(wait: 10.second).perform_later()
    TradeSymbolsPriceFetchJob.perform_later()
  end
end
