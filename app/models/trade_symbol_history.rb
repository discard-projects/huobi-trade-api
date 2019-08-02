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
      if trade_symbol.trade_symbol_histories.between_range_column(:created_at, Time.current - 3.minute, Time.current).where('moment_rate >= ?', addition_rate).present? && trade_symbol.trade_symbol_histories.between_range_column(:created_at, Time.current - 3.minute, Time.current).where('moment_rate <= ?', addition_rate * -1).present?
        last_history = trade_symbol.trade_symbol_histories.where('moment_rate >= ?', addition_rate).last
        User.find_each do |user|
          message = [
            "大行情: `⤴️️ [`#{last_history.trade_symbol.symbol}`][`#{last_history.moment_rate * 100}%`], `#{last_history.previous_close}` -> `#{last_history.close}`",
          ]
          message.push "时间: #{Time.current.strftime('%Y-%m-%d %H:%M:%S')}"
          user.slack_notifier&.ping message.join("\n\n"), {icon_emoji: ':point_right:', mrkdwn: true} rescue nil
        end if last_history
      end
    elsif self.moment_rate <= addition_rate * -1
      if trade_symbol.trade_symbol_histories.between_range_column(:created_at, Time.current - 3.minute, Time.current).where('moment_rate >= ?', addition_rate).present? && trade_symbol.trade_symbol_histories.between_range_column(:created_at, Time.current - 3.minute, Time.current).where('moment_rate <= ?', addition_rate * -1).present?
        last_history = trade_symbol.trade_symbol_histories.where('moment_rate <= ?', addition_rate * -1).last
        User.find_each do |user|
          message = [
            "大行情: `⤵️️ [`#{last_history.trade_symbol.symbol}`][`#{last_history.moment_rate * 100}%`], `#{last_history.previous_close}` -> `#{last_history.close}`",
          ]
          message.push "时间: #{Time.current.strftime('%Y-%m-%d %H:%M:%S')}"
          user.slack_notifier&.ping message.join("\n\n"), {icon_emoji: ':point_right:', mrkdwn: true} rescue nil
        end if last_history
      end
    end

  end
end
