class TradeSymbolPriceFetchJob < ApplicationJob
  queue_as :default

  def perform(trade_symbol_id)
    # Do something later
    huobi = Huobi.new
    trade_symbol = TradeSymbol.find_by(id: trade_symbol_id)
    data = huobi.market_detail(trade_symbol.symbol)
    # p data
    if data && data['status'] == 'ok'
      tick = data['tick']
      trade_symbol.update(amount: tick['amount'], count: tick['count'], open: tick['open'], close: tick['close'], high: tick['high'], low: tick['low'])
    end
  end
end
