class Api::V1::BalanceIntervalsController < Api::V1::BaseController
  def index
    super current_user.balance_intervals
  end

  def destroy
    super do
      current_user.balance_intervals.find_by(id: params[:id]).try(:destroy)
    end
  end
end
