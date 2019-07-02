class TradeSymbol < ApplicationRecord
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
    []
    # User.joins(:balance_plans).where('balance_plans.trade_symbol_id = ?', self.id).uniq | User.joins(:balance_trade_symbols).where('balance_trade_symbols.trade_symbol_id = ?', self.id).uniq | User.joins(:balance_smarts).where('balance_smarts.trade_symbol_id = ?', self.id).uniq
  end
end
