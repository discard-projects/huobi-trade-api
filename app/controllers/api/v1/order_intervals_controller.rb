class Api::V1::OrderIntervalsController < Api::V1::BaseController
  def index
    super current_user.order_intervals
  end
end
