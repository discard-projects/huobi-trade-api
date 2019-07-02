class Api::V1::FootprintsController < Api::V1::BaseController
  before_action :set_trackable, only: [:index]

  def index
    super @trackable.footprints.order(id: :desc)
  end

  private

  def set_trackable
    # model_name 在routes.rb 中指定
    parent_class = params[:model_name].constantize
    parent_foreign_key = params[:model_name].foreign_key
    @trackable = parent_class.find(params[parent_foreign_key])
  end
end
