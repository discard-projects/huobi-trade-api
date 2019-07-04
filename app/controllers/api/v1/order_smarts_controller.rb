class Api::V1::OrderSmartsController < Api::V1::BaseController
  def index
    super current_user.order_smarts
  end
end
