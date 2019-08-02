class TradeSymbolPriceFetchJob < ApplicationJob
  queue_as :default

  def perform(trade_symbol_id)
    # Do something later
    TradeSymbol.find_by(id: trade_symbol_id)&.update_market_detail rescue nil
  end
end
