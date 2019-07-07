class Api::V1::OrderPlansController < Api::V1::BaseController
  def index
    super current_user.order_plans.roots
  end
end
