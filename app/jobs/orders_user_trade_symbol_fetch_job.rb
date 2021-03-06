class OrdersUserTradeSymbolFetchJob < ApplicationJob
  queue_as :default

  # fetch_date: [eg]'2019-09-01'
  def perform(user_id, trade_symbol_id, fetch_date = nil)
    # Do something later
    user = User.find_by(id: user_id)
    trade_symbol = TradeSymbol.find_by(id: trade_symbol_id)
    huobi_api = user.huobi_api
    if huobi_api
      data = huobi_api.orders trade_symbol.symbol, fetch_date
      data && data['data'] && data['data'].each do |o|
        # 如果 订单创建时间 20s内 发现是api下单，却没有找到该订单，则跳过，防止线程冲突，创建相同订单的hid
        if Order.find_by(hid: o['id']).blank? && o['source'] == 'api' && Time.at(o['created-at']/1000).to_datetime + 20.seconds > Time.current
          next
        end
        order = Order.find_or_create_by(hid: o['id'], user:user, account: Account.find_by(hid: o['account-id']), trade_symbol: trade_symbol)
        order.amount = o['amount']
        order.price = o['price']
        order.source = o['source']
        order.hstate = o['state']
        order.symbol = o['symbol']
        order.htype = o['type']
        order.hcancel_at = Time.at(o['canceled-at']/1000).to_datetime
        order.hcreate_at = Time.at(o['created-at']/1000).to_datetime
        order.hfinish_at = Time.at(o['finished-at']/1000).to_datetime
        order.field_amount = o['field-amount']
        order.field_cash_amount = o['field-cash-amount']
        order.field_fees = o['field-fees']

        if order.kind.blank?
          order.kind = 'kind_app'
          if order.source == 'api'
            if order.hcreate_at + 30.seconds > Time.current
              user.slack_notifier&.ping "`#{order.symbol} order[#{order.id}] make by api, but not found interrelated obj immediately, you can check yourself`", {icon_emoji: ':warning:', mrkdwn: true} rescue nil
              next
            end
          end
        end

        # order.status = 'status_created' if order.status.blank?
        if order.category.blank?
          if order.htype =~ /buy/i
            order.category = 'category_buy'
          else
            order.category = 'category_sell'
          end
        end
        if order.save
          order.with_lock do
            # "订单状态	: submitting , submitted 已提交, partial-filled 部分成交, partial-canceled 部分成交撤销, filled 完全成交, canceled 已撤销"
            if order.hstate == 'filled' && order.may_status_filled?
              order.status_filled! rescue nil
            elsif order.hstate == 'partial-filled' && order.may_status_partial_filled?
              order.status_partial_filled!
            elsif order.hstate =~ /canceled/i && order.may_status_canceled?
              order.status_canceled!
            else
            end
          end
        end
      end
    end
  end
end
