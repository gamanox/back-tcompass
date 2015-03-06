module Api
  module V1
    class SessionsController < ApplicationController
      respond_to :json

      def login
        begin
          @user = User.login(params[:user])
          respond_with @user, serializer: UserSerializer
        rescue ActiveRecord::RecordNotFound => invalid
          logger.error invalid.message
          logger.error "User with email: #{params[:user][:email]} does not exist or is in active"
          render json: {error: "User does not exist."},
            status: :internal_server_error
        rescue => invalid
          logger.error invalid
          render json: {error:"Problem authenticating user."},
            status: :internal_server_error
        end
      end

      #TODO: check how password/password_confirmation is sent from web FORM
      def signup
        begin
          @user = current_user.signup(user_params)
          UserMailer.welcome_email(@user,params[:user][:password]).deliver
          render json: {message: "User created"},status: :ok
        rescue ActiveRecord::RecordInvalid => invalid
          message = invalid.record.errors.full_messages.join(',')
          logger.error message
          render json: {error: message},status: :internal_server_error
        rescue => invalid
          logger.error invalid
          render json: {error: "Problem creating user"},
            status: :internal_server_error
        end
      end

      private
        def user_params
          params.require(:user).permit(:name,:last_name,:email,:password,
          :password_confirmation,:group_id)
        end
    end
  end
end
