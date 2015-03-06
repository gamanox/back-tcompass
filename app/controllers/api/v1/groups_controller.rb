module Api
  module V1
    class GroupsController < ApplicationController
      respond_to :json

      def create
        begin
          @group = current_user.groups.create!(group_params)
          render json: {url: "/api/groups"},status: :ok
        rescue ActiveRecord::RecordInvalid => invalid
          logger.error invalid
          render json: {error: invalid.message},
            status: :internal_server_error
        rescue => invalid
          logger.error invalid
          render json: {error:"Problem creating group"},
            status: :server_error
        end
      end

      def index
        begin
          @groups = current_user.groups
          respond_with @groups,each_serializer: GroupSerializer
        rescue => invalid
          logger.error invalid
          render json: {error:"Problem retrieving groups"},status: :not_found
        end
      end

      def show
        begin
          @group = current_user.groups.find(params[:id])
          respond_with @group,serializer: GroupDetailSerializer,root: :group,
            status: :ok
        rescue ActiveRecord::RecordNotFound => invalid
          logger.error invalid
          render json: {error: "Group does not exist"},status: :not_found
        rescue => invalid
          logger.error invalid
          render json: {error:"Problem retrieving group information"},
            status: :internal_server_error
        end
      end

      def group_user
        begin
          Group.find(params[:group_id]).groups_users.create!(group_user_params)
          render json: {url:"api/groups/#{params[:group_id]}"},status: :ok
        rescue ActiveRecord::RecordInvalid => invalid
          logger.error invalid
          render json: {error: "Problem assigning user to group"},
            status: :internal_server_error
        rescue => invalid
          logger.error
          render json: {error:"Problem assigning user to group"},
            status: :server_error
        end
      end

      private
        def group_params
          params.require(:group).permit(:name)
        end

        def group_user_params
          params.require(:user).permit(:user_id)
        end
    end
  end
end
