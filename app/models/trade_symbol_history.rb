class TradeSymbolHistory < ApplicationRecord
  belongs_to :trade_symbol

  before_save :before_save

  after_commit :after_commit

  private

  def before_save
    pre_price = self.previous_close.to_f
    self.moment_rate = ((self.close - pre_price) / pre_price).round(3) rescue 0
  end

  def after_commit
    addition_rate = 0.05

    if self.moment_rate >= addition_rate
      if trade_symbol.trade_symbol_histories.between_range_column(:created_at, Time.current - 1.minute, Time.current).where('moment_rate >= ?', addition_rate).present? && trade_symbol.trade_symbol_histories.between_range_column(:created_at, Time.current - 1.minute, Time.current).where('moment_rate <= ?', addition_rate).present?
        last_history = trade_symbol.trade_symbol_histories.where('moment_rate >= ?', addition_rate).last
        User.find_each do |user|
          user.slack_notifier&.ping "大行情 [`#{last_history.trade_symbol.symbol}`], from: #{last_history.previous_close}, to: #{last_history.close}, 增长率: `#{last_history.moment_rate * 100}%`", {icon_emoji: ':point_right:', mrkdwn: true} rescue nil
        end if last_history
      end
    end

  end
end
