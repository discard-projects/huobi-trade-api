class Api::V1::BalancesController < Api::V1::BaseController
  def index
    super current_user.spot_balances.order(updated_at: :desc)
  end
end
