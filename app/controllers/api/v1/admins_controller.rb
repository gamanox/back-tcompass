module Api
  module V1
    class AdminsController < ApplicationController
        respond_to :json

        #TODO: unauthorized has to return 404 not unauthorized
        def limit_assets
          begin
            raise Unauthorized.new("User") unless current_user.is_admin?
            current_user.clients.find(params[:id]).update!(assets_params)
            render json: {message: "Updated values."},status: :ok
          rescue ActiveRecord::RecordNotFound => invalid
            logger.error invalid
            render json: {error: "Couldn't find User with 'id'=#{params[:id]}"},
              status: :not_found
          rescue Unauthorized => invalid
            message = invalid.log_info
            logger.error invalid.log_info
            render json: {error: message},status: :unauthorized
          rescue => invalid
            logger.error invalid
            render json: {error: "Problem updating value"},
              status: :internal_server_error
          end
        end

        private
          def assets_params
            params.require(:assets).permit(:qty_reports,:qty_branches,:qty_employees)
          end
      end
    end
  end
