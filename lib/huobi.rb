require 'httparty'
# require 'base64'
# require 'openssl'
class Huobi
  def initialize(access_key = '', secret_key = '', signature_version = "2")
    @access_key = access_key
    @secret_key = secret_key
    @signature_version = signature_version
    @uri = URI.parse "https://api.huobi.pro/"
    @header = {
        'Content-Type' => 'application/json',
        'Accept' => 'application/json',
        'Accept-Language' => 'zh-CN',
        'User-Agent' => 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.71 Safari/537.36'
    }
  end

  ## 获取交易对
  def symbols
    request("GET", "/v1/common/symbols", {})
  end

  ## 获取市场深度
  def depth(symbol, type = "step0")
    params = {"symbol" => symbol, "type" => type}
    request("get", "/market/depth", params)
  end

  ## K线数据
  def history_kline(symbol, period, size = 150)
    params = {"symbol" => symbol, "period" => period, "size" => size}
    request("GET", "/market/history/kline", params)
  end

  ## 获取聚合行情(Ticker)
  def merged(symbol)
    params = {"symbol" => symbol}
    request("GET", "/market/detail/merged", params)
  end

  ## 获取 Market Depth 数据
  def market_trade(symbol)
    params = {"symbol" => symbol}
    request("GET", "/market/depth", params)
  end

  ## 获取 Trade Detail 数据
  def trade_detail(symbol)
    params = {"symbol" => symbol}
    request("GET", "/market/trade", params, false)
  end

  ## 批量获取最近的交易记录
  def history_trade(symbol, size = 200)
    params = {"symbol" => symbol, "size" => size}
    request("GET", "/market/history/trade", params, false)
  end

  ## 获取 Market Detail 24小时成交量数据
  def market_detail(symbol)
    params = {"symbol" => symbol}
    request("GET", "/market/detail", params, false)
  end

  ## 查询系统支持的所有币种
  def currencys
    params = {}
    request("GET", "/v1/common/currencys", params)
  end

  ## 查询当前用户的所有账户(即account-id)
  def accounts
    params = {}
    request("GET", "/v1/account/accounts", params)
    # ['data']
  end

  ## 获取账户资产状况
  def balances account_id
    # balances = {"account_id"=>account_id}
    request("GET", "/v1/account/accounts/#{account_id}/balance", {})
    # ['data']['list']
  end

  ## 创建并执行一个新订单
  ## 如果使用借贷资产交易
  ## 请在下单接口/v1/order/orders/place
  ## 请求参数source中填写'margin-api'
  def new_order(account_id, symbol, side, price, count)
    params = {
        "account-id" => account_id,
        "amount" => count,
        "price" => price,
        "source" => "api",
        "symbol" => symbol,
        "type" => "#{side}-limit"
    }
    request("POST", "/v1/order/orders/place", params)
  end

  ## 申请提现虚拟币
  def withdraw_virtual_create(address, amount, currency)
    params = {
        "address" => address,
        "amount" => amount,
        "currency" => currency
    }
    request_method = "POST"
    request("POST", "/v1/dw/withdraw/api/create", params)
  end

  ## 申请取消提现虚拟币
  def withdraw_virtual_cancel(withdraw_id)
    params = {"withdraw_id" => withdraw_id}
    request("POST", "/v1/dw/withdraw-virtual/#{withdraw_id}/cancel", params)
  end

  ## 查询某个订单详情
  def order_status(order_id)
    params = {"order-id" => order_id}
    request("GET", "/v1/order/orders/#{order_id}", params)
  end

  ## 申请撤销一个订单请求
  def submitcancel(order_id)
    params = {"order-id" => order_id}
    request("POST", "/v1/order/orders/#{order_id}/submitcancel", params)
  end

  ## 批量撤销订单
  def batchcancel(order_ids)
    params = {"order-ids" => order_ids}
    request("POST", "/v1/order/orders/batchcancel", params)
  end

  ## 查询某个订单的成交明细
  def matchresults(order_id)
    params = {"order-id" => order_id}
    request("GET", "/v1/order/orders/#{order_id}/matchresults", params)
  end

  ## 查询所有订单
  def orders(symbol, start_date = nil, size = 100)
    params = {
        "symbol" => symbol,
        "states" => "submitted,partial-filled,partial-canceled,filled,canceled",
        "size" => size
    }
    if start_date
      params.merge!({"start-date" => start_date})
    end
    request("GET", "/v1/order/orders", params)
  end

  ## 查询当前委托、历史委托
  def open_orders(symbol, side)
    params = {
        "symbol" => symbol,
        "types" => "#{side}-limit",
        "states" => "pre-submitted,submitted,partial-filled,partial-canceled"
    }
    request("GET", "/v1/order/orders", params)
  end

  ## 查询当前成交、历史成交
  def history_matchresults(symbol)
    params = {"symbol" => symbol}
    request("GET", "/v1/order/matchresults", params, true)
  end

  ## 现货账户划入至借贷账户
  def transfer_in_margin(symbol, currency, amount)
    params = {"symbol" => symbol, "currency" => currency, "amount" => amount}
    request("POST", "/v1/dw/transfer-in/margin", params)
  end

  ## 借贷账户划出至现货账户
  def transfer_out_margin(symbol, currency, amount)
    params = {"symbol" => symbol, "currency" => currency, "amount" => amount}
    request("POST", "/v1/dw/transfer-out/margin", params)
  end

  ## 借贷订单
  def loan_orders(symbol, currency)
    params = {"symbol" => symbol, "currency" => currency}
    request("POST", "/v1/margin/loan-orders", params)
  end

  ## 归还借贷
  def repay(order_id, amount)
    params = {"order-id" => order_id, "amount" => amount}
    request("GET", "/v1/margin/orders/{order-id}/repay", params)
  end

  ## 借贷账户详情
  def margin_accounts_balance(symbol)
    request("GET", "/v1/margin/accounts/balance?symbol=#{symbol}", {})
  end

  ## 申请借贷
  def margin_orders(symbol, currency, amount)
    params = {"symbol" => symbol, "currency" => currency, "amount" => amount}
    request("POST", "/v1/margin/orders", params)
  end

  private

  def request(request_method, path, params, should_sign = true)
    h = params
    if should_sign
      h = {
          "AccessKeyId" => @access_key,
          "SignatureMethod" => "HmacSHA256",
          "SignatureVersion" => @signature_version,
          "Timestamp" => Time.now.getutc.strftime("%Y-%m-%dT%H:%M:%S")
      }
      h = h.merge(params) if request_method == "GET"
      data = "#{request_method}\napi.huobi.pro\n#{path}\n#{URI.encode_www_form(hash_sort(h))}"
      h["Signature"] = sign(data)
    end
    url = "https://api.huobi.pro#{path}?#{URI.encode_www_form(h)}"
    http = Net::HTTP.new(@uri.host, @uri.port)
    http.use_ssl = true
    begin
      JSON.parse http.send_request(request_method, url, JSON.dump(params), @header).body
    rescue Exception => e
      {"message" => 'error', "request_error" => e.message}
    end
  end

  def sign(data)
    Base64.encode64(OpenSSL::HMAC.digest('sha256', @secret_key, data)).gsub("\n", "")
  end

  def hash_sort(ha)
    Hash[ha.sort_by {|key, val| key}]
  end
end

# access_key = 'vqgdf4gsga-aed5e526-7efce3b7-60407'
# secret_key = '38939ebe-6a886198-cecaa157-43fea'
# account_id = '6125085'
# huobi = Huobi.new(access_key, secret_key)
# huobi = Huobi.new
# p huobi.accounts
# p huobi.balances 6125085
# p huobi.symbols
# p huobi.depth('ethbtc')
# p huobi.history_kline('ethbtc',"1min")
# p huobi.merged('ethbtc')
# p huobi.trade_detail('ethbtc')
# p huobi.history_trade('ethbtc')
# # 最近市场成交记录
# p Huobi.new.trade_detail('rsrusdt')
# p Huobi.new.history_trade('rsrusdt')
# p huobi.market_detail 'rsrusdt'