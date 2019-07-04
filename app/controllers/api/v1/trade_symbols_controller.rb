class Api::V1::TradeSymbolsController < Api::V1::BaseController
  # skip_before_action :authenticate_user!, only: [:index]
  def index
    super TradeSymbol.order(enabled: :desc)
  end

  def toggle_switch
    trade_symbol = TradeSymbol.find(id: params[:id])
    # 如果目前是开启状态要关闭，但是已经有纳入的用户，拒绝关闭
    if trade_symbol.enabled && trade_symbol.users.present?
      render json: {msg: 'invalid! can not switch'}, status: 422 and return
    else
      super
    end
  end
end
