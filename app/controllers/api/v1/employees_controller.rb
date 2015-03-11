module Api
  module V1
    class EmployeesController < ApplicationController
      respond_to :json
      include EmployeesHelper

      def show
        begin
          #@employee = current_user.employees.find(params[:id])
          @employee = User.find(params[:id])
          if params[:date_filter]
            filter_by_date([@employee],params[:date_filter])
          end
          respond_with @employee,serializer: EmployeeSerializer
        rescue ActiveRecord::RecordNotFound => invalid
          logger.error invalid
          render json: {error: "User not found."},
            status: :not_found
        rescue => invalid
          logger.error invalid
          render json: {error: "Problem retrieving user."},
            status: :internal_server_error
        end
      end

      def destroy
        begin
          current_user.employees.find(params[:id]).update!(is_active: false)
          render json: {message: "Employee is now inactive."},status: :ok
        rescue ActiveRecord::RecordInvalid => invalid
          logger.error invalid
          render json: {message: invalid.message},status: :internal_server_error
        rescue => invalid
          render json: {error: "Problem deleting user."},
            status: :internal_server_error
        end
      end

      def update
        begin
          current_user.employees.find(params[:id]).update!(employee_params)
          render json: {message: "Employee information updated",
            url: "/api/employees/#{params[:id]}"},status: :ok
        rescue ActiveRecord::RecordInvalid => invalid
          logger.error invalid
          render json: {error: invalid.message},status: :internal_server_error
        rescue => invalid
          logger.error invalid
          render json: {error: "Problem updating employee information"},
          status: :internal_server_error
        end
      end

      def assign_groups
        begin
          current_user.employees.find(params[:id]).assign_groups(params[:groups_ids])
          render json: {message: "User assigned to groups"}
        rescue ActiveRecord::RecordNotFound => invalid
          logger.error invalid
          render json: {error: "One or more groups does not exist."}
        rescue => invalid
          logger.error invalid
          render json: {error: "Problem assigning user to groups"},
          status: :internal_server_error
        end
      end

      def index_reports
        begin
          groups =
            Group.select(:id).joins(:groups_users).where("groups_users.user_id = ?",current_user.id)
          @reports = Report.joins(:group_reports).where("reports.is_active = true AND
            group_reports.group_id IN (?)",groups).uniq
          respond_with @reports,each_serializer: ReportSerializer,root: :reports
        rescue => invalid
          logger.error invalid
          render json: {error: "Problem retrieving reports for user"},
            status: :internal_server_error
        end
      end

      def branches
        begin
          # 1.- Get ids of the groups this user belongs (get branches in the same group(s))
          user_groups =
            Group.select(:id).joins(:groups_users).where("groups_users.user_id = ?",current_user.id)
          # 2.- Get ids of branches that are not in a group
          branches_ids =
            current_user.client.branches.joins(group_branches: :group).select(:id)
          # 3.- Get branches that are in the same group(s) as the user
          # or that do not have an assigned group/groups
          @group_branches =
            Branch.joins(:group_branches).where("group_branches.group_id IN (?)
             AND branches.is_active = true",
              user_groups).uniq
          @client_branches = Branch.where("branches.id NOT IN (?) AND
           branches.user_id = ? AND branches.is_active = true",
           branches_ids,current_user.client.id).uniq
          @branches = @group_branches+@client_branches
          respond_with @branches,each_serializer: BranchSerializer,root: :places
        rescue => invalid
          logger.error invalid
          render json: {error: "Problem retrieving branches for user"},
          status: :internal_server_error
        end
      end

      def shifts
        begin
          current_user.employee_locations.create!(shift_params)
          render json: {message: "Successful"}
        rescue ActiveRecord::RecordInvalid => invalid
          logger.error invalid
          render json: {error: "There was a problem"},
            status: :internal_server_error
        rescue => invalid
          logger.error invalid
          render json: {error: "There was a problem"},
            status: :internal_server_error
        end
      end

      def change_status
        begin
          user = current_user.employees.find(params[:id])
          user.toggle_is_active!
          user_json = UserDetailSerializer.new(user,root: :user)
          render json: user_json
        rescue ActiveRecord::RecordNotFound => invalid
          logger.error invalid
          render json: {error: "User not found."},
            status: :not_found
        rescue => invalid
          logger.error invalid
          render json: {error: "There was a problem"},
            status: :internal_server_error
        end
      end

      def reports_done
        begin
          @reports = current_user.user_reports.map {|r| Report.find(r.report_id)}
          @reports.each do |r|
            r.place_name =
              current_user.user_reports.where(report_id: r.id).first.branch.name
            r.pages.each do |p|
              p.questions.each do |q|
                q.filtered_responses = q.responses.where(user_id: current_user.id,
                  question_id: q.id)
              end
            end
          end
          respond_with @reports,each_serializer: ReportDetailSerializer,root: :report
        rescue => invalid
          logger.error invalid
          render json: {error: "Problem retrieving messages."},
            status: :internal_server_error
        end
      end

      private
        def shift_params
          params.require(:shift).permit(:latlng,:location_type)
        end

        def employee_params
          params.require(:employee).permit(:name,:last_name,:email,:password,
            :password_confirmation,:birthday,:phone)
        end
    end
  end
end
