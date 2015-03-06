module Api
  module V1
    class BranchesController < ApplicationController
      respond_to :json

      def assign_groups
        begin
          current_user.branches.find(params[:id]).assign_groups(params[:groups_ids])
          render json: {message: "Branch assigned to groups"}
        rescue ActiveRecord::RecordInvalid => invalid
          logger.error invalid
          render json: {error:
            "Branch is already in group with 'id'=#{invalid.record.group_id}"},
            status: :internal_server_error
        rescue => invalid
          logger.error invalid
          render json: {error: "Problem assigning report to groups"},
            status: :internal_server_error
        end
      end

      def show
        begin
          @branch = current_user.branches.find(params[:id])
          respond_with :api,@branch,serializer: BranchDetailSerializer,root: :branch
        rescue ActiveRecord::RecordNotFound => invalid
          logger.error invalid
          render json: {error: "Couldn't find Branch with 'id'=#{params[:id]}"},
            status: :not_found
        rescue
          render json: {error: "Problem retrieving branch"},
            status: :internal_server_error
        end
      end

      def update
        begin
          current_user.branches.find(params[:id]).update_columns(branch_params)
          render json: {message: "Branch information updated",
            url: "/api/branches/#{params[:id]}"}, status: :ok
        rescue ActiveRecord::RecordNotFound => invalid
          logger.error invalid
          render json: {error: "Couldn't find Branch with 'id'=#{params[:id]}"},
            status: :not_found
        rescue ActiveRecord::RecordInvalid => invalid
          logger.error invalid
          render json: {error: "Problem updating branch information"},
            status: :internal_server_error
        rescue => invalid
          logger.error invalid
          render json: {error: "Problem updating branch information"},
            status: :internal_server_error
        end
      end

      def toggle_is_active
        begin
          @branch = current_user.branches.find(params[:id])
          @branch.toggle_is_active!
          respond_with :api,@branch,serializer: BranchDetailSerializer,root: :branch
        rescue ActiveRecord::RecordNotFound => invalid
          logger.error invalid
          render json: {error: "Couldn't find Branch with 'id'=#{params[:id]}"},
            status: :not_found
        rescue ActiveRecord::RecordInvalid => invalid
          logger.error invalid
          render json: {error: "Problem updating branch information"},
            status: :internal_server_error
        rescue => invalid
          logger.error invalid
          render json: {error: "There was a problem changing branch status"},
            status: :internal_server_error
        end
      end

      private
        def branch_params
          params.require(:branch).permit(:name,:address,:latlng,:is_active,:description,
          :phone,:email)
        end
    end
  end
end
