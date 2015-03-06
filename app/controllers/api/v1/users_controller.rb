module Api
  module V1
    class UsersController < ApplicationController
      respond_to :json
      include EmployeesHelper

      def employees
        begin
          @employees = ActiveModel::ArraySerializer.new(
            current_user.employees,
            each_serializer: EmployeeDetailSerializer
          )
          @limits = {
            employee_count: current_user.employees.count,
            employee_total: current_user.qty_employees
          }
          resp_json = {
            employees: @employees,
            limits: @limits
          }
          render json: resp_json
        rescue => invalid
          logger.error invalid
          render json: {error: "Problem retrieving employees"},
            status: :internal_server_error
        end
      end

      def employee_location
        begin
          unless params[:location][:latlng].class.nil?
            @location = current_user.employee_locations.create!(online_location_params)
          else
            params[:location][:locations].each do |l|
              current_user.employee_locations.create!(offline_location_params(l))
            end
          end
          render json: {message: "Location updated"},status: :ok
        rescue ActiveRecord::RecordInvalid => invalid
          logger.error invalid
          render json: {error: "Problem updating location"},
          status: :internal_server_error
        rescue => invalid
          logger.error invalid
          render json: {error: "Problem updating location"},
            status: :internal_server_error
        end
      end

      def locations
        begin
          @users = current_user.filtered_employees(params[:group_id])
          filter_by_date(@users,params[:date_filter])
          @users.each do |u|
            u.reports_date_filter(params[:date_filter])
          end
          serialized_users =
            ActiveModel::ArraySerializer.new(@users,each_serializer: UserLocationSerializer)
          calc_kpis = get_kpis(@users,params[:date_filter])
          serialized_branches =
            ActiveModel::ArraySerializer.new(current_user.branches,
            each_serializer: BranchSerializer)
          resp_json = {kpis: calc_kpis,users: serialized_users,
            branches: serialized_branches}
          render json: resp_json
        rescue => invalid
          logger.error invalid.backtrace.take(5).join("\n")
          render json: {error: "Problem retrieving locations"},
            status: :internal_server_error
        end
      end

      private
        def online_location_params
          params.require(:location).permit(:latlng)
        end

        def offline_location_params(param)
          ActionController::Parameters.new(param.to_hash).permit(:latlng,:created_at)
        end
    end
  end
end
