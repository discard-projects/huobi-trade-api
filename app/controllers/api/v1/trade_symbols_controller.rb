class Api::V1::TradeSymbolsController < Api::V1::BaseController
  # skip_before_action :authenticate_user!, only: [:index]
  def index
    @is_manager = current_user.is_manager?
    super TradeSymbol.order(enabled: :desc)
  end

  def toggle_switch
    if current_user.is_manager?
      super
    end
  end
end
