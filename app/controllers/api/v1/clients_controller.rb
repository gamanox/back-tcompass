module Api
  module V1
    class ClientsController < ApplicationController
      respond_to :json
      include BranchesHelper

      #TODO: unauthorized has to return 404 not unauthorized
      def index
        begin
          clients = current_user.clients
          respond_with clients,each_serializer: ClientSerializer
        rescue Unauthorized => invalid
          message = invalid.log_info
          logger.error message
          render json: {error: message},status: :unauthorized
        rescue => invalid
          logger.error invalid
          render json: {error: "Problem retrieving clients"},
            status: :internal_server_error
        end
      end

      def show
        begin
          client = current_user.clients.find(params[:id])
          respond_with client,serializer: ClientSerializer
        rescue ActiveRecord::RecordNotFound => invalid
          logger.error invalid
          render json: {error: "Couldn't find Client with 'id'=#{params[:id]}"},
            status: :not_found
        rescue => invalid
          logger.error invalid
          render json: {error: "Problem retrieving client information"},
            status: :internal_server_error
        end
      end

      def create
        begin
          @client = current_user.clients.create!(client_params)
          UserMailer.welcome_email(@client,params[:client][:password]).deliver
          render json: {message: "Client created."},status: :ok
        rescue ActiveRecord::RecordInvalid => invalid
          logger.error invalid
          render json: {error: "Problem creating user."},
            status: :internal_server_error
        rescue => invalid
          logger.error invalid
          render json: {error: "Problem creating user."},
            status: :internal_server_error
        end
      end

      def destroy
        begin
          current_user.clients.where("users.is_active = true").
            find(params[:id]).update!(is_active: false)
          render json: {message: "Client deleted."},status: :ok
        rescue ActiveRecord::RecordNotFound => invalid
          logger.error invalid
          render json: {error: "Couldn't find Client with 'id'=#{params[:id]}"},
            status: :not_found
        rescue => invalid
          render json: {error: "Problem deleting user."},
            status: :internal_server_error
        end
      end

      def create_branch
        begin
          @branch = current_user.branches.create!(branch_params)
          render json: {message: "Branch created."},status: :ok
        rescue ActiveRecord::RecordInvalid => invalid
          message = invalid.record.errors.map {|k,v| "#{k}: #{v}"}.join(',')
          logger.error message
          render json: {error: message},status: :internal_server_error
        rescue
          render json: {error: "Problem creating branch."},
            status: :internal_server_error
        end
      end

      def index_branch
        begin
          @branches = ActiveModel::ArraySerializer.new(
            current_user.branches,
            each_serializer: BranchSerializer
          )
          @limits = {
            branch_count: current_user.branches.count,
            branch_limit: current_user.qty_branches
          }
          resp_json = {branches: @branches,limits: @limits}
          render json: resp_json
        rescue
          render json: {error: "Problem retrieving branches."},
            status: :internal_server_error
        end
      end

      private
        def client_params
          params.require(:client).permit(:name,:address,:latlng,:qty_reports,
            :qty_employees,:email,:qty_branches,:password,:password_confirmation)
        end

        def branch_params
          params.require(:branch).permit(:name,:address,:latlng,:description,:phone,:email)
        end
    end
  end
end
