class TradeSymbolHistory < ApplicationRecord
  belongs_to :trade_symbol

  before_save :before_save

  after_commit :after_commit

  private

  def before_save

  end

  def after_commit
    if trade_symbol.trade_symbol_histories.where('moment_rate >= ?', 0.1).present? && trade_symbol.trade_symbol_histories.where('moment_rate <= ?', 0.1).present?
      last_history = trade_symbol.trade_symbol_histories.where('moment_rate >= ?', 0.1).last
      User.find_each do |user|
        user.slack_notifier&.ping "大行情[#{self.symbol}], from: #{last_history.previous_close}, to: #{last_history.close}", {icon_emoji: ':point_right:', mrkdwn: true} rescue nil
      end
    end
  end
end
