class Api::V1::BalanceSmartsController < Api::V1::BaseController
  def index
    super current_user.balance_smarts
  end

  def destroy
    super do
      current_user.balance_smarts.find_by(id: params[:id]).try(:destroy)
    end
  end
end
