class Api::V1::UserController < Api::V1::BaseController
  skip_before_action :authenticate_user!, only: [:create]

  def create
    super
  end
end
