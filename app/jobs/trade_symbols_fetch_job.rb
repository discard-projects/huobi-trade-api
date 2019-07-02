class TradeSymbolsFetchJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Do something later
    data = Huobi.new.symbols['data']
    # p data
    data && data.each do |tb|
      TradeSymbol.find_or_create_by(base_currency: tb['base-currency'], quote_currency: tb['quote-currency']) do |trade_symbol|
        trade_symbol.price_precision = tb['price-precision']
        trade_symbol.amount_precision = tb['amount-precision']
        trade_symbol.symbol_partition = tb['symbol-partition']
        trade_symbol.symbol = tb['symbol']
      end
    end
    TradeSymbolsFetchJob.perform_later()
  end
end
