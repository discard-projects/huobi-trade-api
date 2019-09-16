class TradeSymbol < ApplicationRecord

  has_many :balance_intervals
  has_many :balance_plans
  has_many :balance_smarts
  has_many :trade_symbol_histories

  after_commit :after_commit

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

  def exist_enabled_config?
    self.balance_intervals.where(enabled: true).present? || self.balance_plans.where(enabled: true).present? || self.balance_smarts.where(enabled: true).present?
  end

  def update_market_detail
    data = Huobi.new.market_detail(self.symbol)
    if data && data['status'] == 'ok'
      tick = data['tick']
      self.update(amount: tick['amount'], count: tick['count'], open: tick['open'], close: tick['close'], high: tick['high'], low: tick['low'])
    else
      Rails.cache.fetch("TradeSymbolApiGetPrice:#{self.id}", expires_in: 4.hours) do
        $slack_bug_notifier&.ping "[`error`] fetch trade_symbol #{self.symbol} price: #{data}", {icon_emoji: ':point_right:', mrkdwn: true} rescue nil
      end unless /^767/.match(data['request_error'])
    end
  end

  private

  def after_commit
    if previous_changes.key?(:close)
      TradeSymbolHistory.create(trade_symbol: self, amount: self.amount, count: self.count, open: self.open, close: self.close, high: self.high, low: self.low, previous_close: previous_changes[:close].first || 0)
    end
  end
end
