class Api::V1::OrdersController < Api::V1::BaseController
  # skip_before_action :authenticate_user!

  def index
    super current_user.orders.roots.order(:created_at, :updated_at)
  end

  def create
    params[:user_id] = current_user.id
    params[:worker_id] = Worker.find_by(no: params[:worker_no]).try(:id)
    if params[:service_person]
      params[:service_person][:user_id] = current_user.id
    end
    super
  end

  def change_status
    status = params[:status]
    order = current_user.orders.find_by(id: params[:id])
    if order&.send("may_#{status}?")
      order.send("#{status}!")
      render json: {message: 'successfully_update'}, status: 200
    else
      render json: {message: '权限拒绝'}, status: 422
    end
  end

  # def update
  #   order = current_user.orders.find_by(oid: params[:oid])
  #   super if order.user_id == current_user.id
  # end

  # def destroy
  #   order = current_user.orders.find_by(oid: params[:oid])
  #   super if order.user_id == current_user.id
  # end
end
