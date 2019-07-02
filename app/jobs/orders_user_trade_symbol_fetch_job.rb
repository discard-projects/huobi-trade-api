class OrdersUserTradeSymbolFetchJob < ApplicationJob
  queue_as :default

  def perform(user_id, trade_symbol_id)
    # Do something later
    user = User.find_by(id: user_id)
    trade_symbol = TradeSymbol.find_by(id: trade_symbol_id)
    huobi_api = user.huobi_api
    if huobi_api
      data = huobi_api.orders trade_symbol.symbol
      data['data'] && data['data'].each do |o|
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
              order.status_filled!
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
