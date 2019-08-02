class TradeSymbolHistory < ApplicationRecord
  belongs_to :trade_symbol

  before_save :before_save

  after_commit :after_commit

  private

  def before_save
    self.moment_rate = (self.previous_close.to_f / self.close).round(2)
  end

  def after_commit
    if trade_symbol.trade_symbol_histories.between_range_column(:created_at, Time.current - 1.minute, Time.current).where('moment_rate >= ?', 0.01).present? && trade_symbol.trade_symbol_histories.between_range_column(:created_at, Time.current - 1.minute, Time.current).where('moment_rate <= ?', 0.01).present?
      last_history = trade_symbol.trade_symbol_histories.where('moment_rate >= ?', 0.01).last
      User.find_each do |user|
        user.slack_notifier&.ping "大行情[#{self.symbol}], from: #{last_history.previous_close}, to: #{last_history.close}", {icon_emoji: ':point_right:', mrkdwn: true} rescue nil
      end
    end
  end
end
