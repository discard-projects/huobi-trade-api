class Api::V1::UserController < Api::V1::BaseController
  skip_before_action :authenticate_user!, only: [:create]

  def create
    super do |is_success|
      AccountsFetchJob.perform_later() if is_success
    end
  end
end
