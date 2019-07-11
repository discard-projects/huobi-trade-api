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

      validates :buy_percent, numericality: { greater_than_or_equal_to: 2 }
      validates :sell_percent, numericality: { greater_than_or_equal_to: 0.5 }

      validate :valid_values

      def valid_values
        if self.enabled
          if self.id.blank?
            trade_symbol = TradeSymbol.find_by(id: self.trade_symbol_id)
            errors.add(:open_price, "open_price[#{self.open_price}] 价格必须小于等于当前值 #{trade_symbol.current_price}") if self.open_price.to_f > trade_symbol.current_price * 1.005
          else
            errors.add(:enabled, "[open_price: #{self.open_price}, amount: #{self.amount}] can not reopen, please create a new one") unless self.model.enabled
          end
        end
      end
    end

    collection :balance_plans, populate_if_empty: BalancePlan do
      property :balance_id
      property :trade_symbol_id
      property :begin_price
      property :end_price
      property :interval_price
      property :open_price
      property :amount
      property :addition_amount
      property :enabled

      validates :balance_id, :trade_symbol_id, presence: true
      validates :begin_price, :end_price, :interval_price, :open_price, :amount, numericality: { greater_than: 0 }

      validate :valid_values
      def valid_values
        if self.enabled
          if self.id.blank?
            trade_symbol = TradeSymbol.find_by(id: self.trade_symbol_id)
            errors.add(:open_price, "open_price[#{self.open_price}] 价格必须小于等于当前值 #{trade_symbol.current_price}") if self.open_price.to_f > trade_symbol.current_price
          end
          errors.add(:begin_price, "begin_price 价格必须小于等于 open_price #{self.open_price}") if self.begin_price.to_f > self.open_price.to_f
          errors.add(:end_price, "end_price 价格必须大于等于 open_price #{self.open_price}") if self.open_price.to_f >= self.end_price.to_f
        end
      end
    end
  end
end