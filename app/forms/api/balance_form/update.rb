module Api::BalanceForm
  class Update < ReformBase
    model :balance

    collection :balance_intervals, populate_if_empty: BalanceInterval do
      property :balance_id
      property :trade_symbol_id
      property :buy_price
      property :sell_price
      property :amount
      property :enabled

      validates :balance_id, :trade_symbol_id, presence: true
      validates :buy_price, :sell_price, :amount, numericality: { greater_than: 0 }
      # validates :cus_buy_price, :cus_sell_price, :cus_count, numericality: { greater_than_or_equal_to: 0 }

      validate :valid_values
      def valid_values
        if self.enabled && self.id.blank?
          trade_symbol = TradeSymbol.find_by(id: self.trade_symbol_id)
          errors.add(:buy_price, "价格必须小于等于当前值 #{trade_symbol.current_price}") if self.buy_price.to_f > trade_symbol.current_price
          errors.add(:sell_price, "价格必须大于购买值 #{self.buy_price}") if self.buy_price.to_f >= self.sell_price.to_f
        end
      end
    end

    collection :balance_smarts, populate_if_empty: BalanceSmart do
      property :balance_id
      property :trade_symbol_id
      property :open_price
      property :amount
      property :buy_percent
      property :rate_amount
      property :max_amount
      property :sell_percent

      property :enabled

      validates :balance_id, :trade_symbol_id, presence: true

      validate :valid_values

      def valid_values
        if self.enabled && self.id.blank?
          trade_symbol = TradeSymbol.find_by(id: self.trade_symbol_id)
          errors.add(:open_price, "open_price[#{self.open_price}] 价格必须小于等于当前值 #{trade_symbol.current_price}") if self.open_price.to_f > trade_symbol.current_price * 1.005
        end
      end
    end
  end
end