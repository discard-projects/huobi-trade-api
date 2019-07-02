class Api::BaseController < ApplicationController
  before_action :authenticate_user!, unless: :devise_controller?
  around_action :set_thread_footprint_actor, unless: :devise_controller?

  private

  # def current_user
  #   super || User.first
  # end

  def set_thread_footprint_actor
    Footprintable::Current.actor = current_user
    yield
  ensure
    # to address the thread variable leak issues in Puma/Thin webserver
    Footprintable::Current.actor = nil
  end
end
