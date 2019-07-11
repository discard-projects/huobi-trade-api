class TradeSymbol < ApplicationRecord

  has_many :balance_intervals

  def current_price
    close || 0
  end

  def less_than_current_price
    if self.current_price && self.price_precision && self.current_price > 0 && self.price_precision > 0
      little_minus = 0.1 ** self.price_precision
      little_minus / current_price <= 0.001 ? current_price - little_minus : current_price
    else
      current_price || 0
    end
  end

  def users
    User.joins(:balance_intervals).where('balance_intervals.trade_symbol_id = ?', self.id).uniq | User.joins(:balance_smarts).where('balance_smarts.trade_symbol_id = ?', self.id).uniq | User.joins(:balance_plans).where('balance_plans.trade_symbol_id = ?', self.id).uniq
  end

  def update_market_detail
    data = Huobi.new.market_detail(self.symbol)
    if data && data['status'] == 'ok'
      tick = data['tick']
      self.update(amount: tick['amount'], count: tick['count'], open: tick['open'], close: tick['close'], high: tick['high'], low: tick['low'])
    end
  end
end
