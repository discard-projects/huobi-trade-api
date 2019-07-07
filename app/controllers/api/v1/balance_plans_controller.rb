class Api::V1::BalancePlansController < Api::V1::BaseController
  def index
    super current_user.balance_plans
  end

  def destroy
    super do
      current_user.balance_plans.find_by(id: params[:id]).try(:destroy)
    end
  end
end
