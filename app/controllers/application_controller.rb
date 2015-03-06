class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  include SessionsHelper

  before_action :check_session

  private
    # TODO: user begin/rescue
    def check_session
      begin
        url = "/api/login"
        if current_user.nil? && (url != api_login_path)
          raise NoSession.new("User")
        end
      rescue => invalid
        logger.error invalid
        render json: {error: "No active session"},status: :unauthorized
      end
    end
end
