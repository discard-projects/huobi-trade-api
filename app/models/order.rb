class Order < ApplicationRecord
  include AASM
  has_ancestry

  belongs_to :user
  belongs_to :account
  belongs_to :trade_symbol
  belongs_to :balancable, polymorphic: true, optional: true
  belongs_to :tradable, polymorphic: true, optional: true

  # app购买 系统自动买入 定义价格买入卖出
  enum kind: { kind_app: 0, kind_interval: 1, kind_plan: 2, kind_smart: 3 }
  ransacker :kind, formatter: proc { |v| kinds[v] }

  # category buy/sell
  enum category: { category_buy: 0, category_sell: 1 }
  ransacker :category, formatter: proc { |v| categories[v] }

  # status
  enum status: { status_created: 0, status_partial_filled: 1, status_filled: 2, status_finished: 3, status_canceled: 4 }
  ransacker :status, formatter: proc { |v| statuses[v] }

  aasm :column => :status, :enum => true do
    state :status_created, :initial => true
    state :status_partial_filled, :status_filled, :status_finished, :status_canceled
    event :status_partial_filled do
      transitions :from => :status_created, :to => :status_partial_filled
    end
    event :status_filled, after: :after_status_traded do
      transitions :from => [:status_created, :status_partial_filled], :to => :status_filled
    end
    event :status_finished do
      transitions :from => [:status_filled], :to => :status_finished
    end
    event :status_canceled, after: :after_status_canceled do
      transitions :from => :status_created, :to => :status_canceled
    end
  end

  def resolve_amount
    (self.field_amount - self.field_fees).floor(trade_symbol.price_precision)
  end

  def field_profit_to_usdt
    usdt_count = self.field_profit
    if trade_symbol.quote_currency != 'usdt'
      usdt_count = TradeSymbol.find_by(symbol: "#{trade_symbol.quote_currency}usdt").current_price * usdt_count
    end
    usdt_count.round(2)
  end

  def send_traded_notification
    message = [
      "主题: `#{self.kind} #{self.category == 'category_sell' ? '卖出' : '买入'}#{trade_symbol.base_currency}` [#{self.id}], 价格: #{self.price}, 数量: #{self.amount}, 约合: #{trade_symbol.quote_currency} #{self.field_amount * self.price}",
    ]
    if category == 'category_sell' && self.field_profit != 0
      message.push("本次盈利: `usdt #{self.field_profit_to_usdt rescue nil}`")
    end
    message.push "时间: #{self.hfinish_at.try(:strftime, '%Y-%m-%d %H:%M:%S')}"
    message.push "邮箱: #{self.user.email}"
    message.push "- - - - - - - - - End - - - - - - - - -"
    user.slack_notifier&.ping message.join("\n\n"), { icon_emoji: ':watermelon:', mrkdwn: true } rescue nil
  end

  def self.api_make! account, trade_symbol, side, price, amount, kind
    user = account.user
    huobi_api = user.huobi_api
    if huobi_api
      price = side == 'buy' ? price.floor(trade_symbol.price_precision) : price.ceil(trade_symbol.price_precision)
      amount = amount.floor(trade_symbol.amount_precision)
      res = huobi_api.new_order(account.hid, trade_symbol.symbol, side, price, amount.to_i == amount ? amount.to_i : amount)
      if res && res['status'] == 'ok'
        Order.create(hid: res['data'], user_id: account.user_id, account: account, trade_symbol: trade_symbol, category: side == 'buy' ? 'category_buy' : 'category_sell', price: price, amount: amount, kind: kind)
      else
        data = huobi_api.orders trade_symbol.symbol
        o = data && data['data'] && data['data'].find do |o|
          o['price'] == price && o['amount'] == amount && Order.find_by(hid: o['hid']).blank?
        end
        if o
          Order.create(hid: o['hid'], user_id: account.user_id, account: account, trade_symbol: trade_symbol, category: side == 'buy' ? 'category_buy' : 'category_sell', price: price, amount: amount, kind: kind)
        else
          Rails.cache.fetch("OrderApiMakeError:user:#{user.id}", expires_in: 10.seconds) do
            user.slack_notifier&.ping "[`error`] create #{trade_symbol.symbol} order error: #{res}", {icon_emoji: ':point_right:', mrkdwn: true} rescue nil
          end
          raise "create #{trade_symbol.symbol} order error: #{res}"
        end
      end
    end
  end

  private

  def after_status_traded
    if self.tradable&.may_status_traded?
      self.tradable.status_traded!
    end
    # app下单直接发送通知，其他通知由tradable对象处理
    if self.kind == 'kind_app'
      self.send_traded_notification rescue nil
    end
  end

  def after_status_canceled
    # 如果有归属，归属也取消掉
    if self.tradable&.may_status_canceled?
      self.tradable.status_canceled!
    end
  end
end
