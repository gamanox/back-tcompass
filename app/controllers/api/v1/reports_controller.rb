module Api
  module V1
    class ReportsController < ApplicationController
      respond_to :json
      include ReportsHelper

      def index
        begin
          @reports = ActiveModel::ArraySerializer.new(
            current_user.reports,
            each_serializer: ReportTableSerializer
          )
          @limits = {
            report_count: current_user.reports.count,
            report_limit: current_user.qty_reports
          }
          resp_json = {
            reports: @reports,
            limits: @limits
          }
          render json: resp_json
        rescue => invalid
          logger.error invalid
          render json: {error: "Problem retrieving reports"},
            status: :internal_server_error
        end
      end

      def create
        begin
          @report = current_user.reports.create!(report_params)
          render json: {message: "Report created"}
        rescue ActiveRecord::RecordInvalid => invalid
          message = invalid.record.errors.messages[:qty_reports].first
          logger.error message
          render json: {error: message},status: :internal_server_error
        rescue => invalid
          logger.error invalid
          render json: {error: "Problem creating report"},
            status: :internal_server_error
        end
      end
      def reporte_ind
        begin
          date=params[:date_filter]
          puts date.to_yaml
          @userdata = {
            full_name: User.find(params[:user_id]).name+" "+User.find(params[:user_id]).last_name,
            group: GroupsUser.find_by_user_id(params[:user_id]).group.name,
            branch: Branch.find(params[:branch_id]).name,
            date: date
          }
          resp_json = @userdata

          render json: {user: resp_json},status: :ok
        
        rescue ActiveRecord::RecordInvalid => invalid
          message = invalid.record.errors.messages[:qty_reports].first
          logger.error message
          render json: {error: message},status: :internal_server_error
        
        rescue => invalid
          logger.error invalid
          render json: {error: "Problem fetching report info"},
            status: :internal_server_error
        end
      end
      def show
        begin
          @report = current_user.reports.find(params[:id])
          
          @report.pages.each do |p|
            p.questions.each do |q|
              q.filter_responses(params[:user_id],params[:branch_id],params[:date_filter])
            end
          end
          respond_with @report,serializer: ReportDetailSerializer,root: :report
        rescue => invalid
          logger.error invalid
          render json: {error: "Problem retrieving report"},
            status: :internal_server_error
        end
      end

      def toggle_is_active
        begin
          @report = current_user.reports.find(params[:id])
          @report.toggle_is_active!
          respond_with :api,@report,serializer: ReportSerializer,root: :report
        rescue ActiveRecord::RecordNotFound => invalid
          logger.error invalid
          render json: {error: "Couldn't find Report with 'id'=#{params[:id]}"},
            status: :not_found
        rescue ActiveRecord::RecordInvalid => invalid
          logger.error invalid
          render json: {error: "Problem updating report information"},
            status: :internal_server_error
        rescue => invalid
          logger.error invalid
          render json: {error: "There was a problem changing report status"},
            status: :internal_server_error
        end
      end

      def create_responses
        begin
          current_user.employee_locations.create!(latlng: params[:report][:latlng],
            location_type: 3)
          current_user.user_reports.
            create!(user_report_params(params[:report][:report_id],params[:report][:branch_id]))
          @branch = Branch.find(params[:report][:branch_id])
          params[:report][:pages].each do |page|
            page[:responses].each do |res|
              if res[:question_type] == 6
                decode_image(res)
              end
              created_resp = current_user.responses.create!(response_params(res))
              @branch.branch_responses.create!(branch_response_params(created_resp.id))
              clean_tmp_file
            end
          end
          render json: {message: "Responses created."}
        rescue ActiveRecord::RecordInvalid => invalid
          logger.error invalid
          render json: {error: "Problem creating responses"},
            status: :internal_server_error
        rescue => invalid
          logger.error invalid
          render json: {error: "Problem creating responses"},
            status: :internal_server_error
        end
      end

      def assign_groups
        begin
          current_user.reports.find(params[:id]).assign_groups(params[:groups_ids])
          render json: {message: "Report assigned to groups"}
        rescue ActiveRecord::RecordNotFound => invalid
          logger.error invalid
          render json: {error: "Can't find report"},
            status: :internal_server_error
        rescue => invalid
          logger.error invalid
          render json: {error: "Problem assigning report to groups"},
            status: :internal_server_error
        end
      end

      #TODO: refactor date_filter to an external method
      def export
        begin
          @report = current_user.reports.find(params[:id])
          @userResponses = UserReport.select(:user_id).where(report_id: params[:id])
          print current_user.name
          if params[:date_filter]
            @report.pages.each do |p|
              p.questions.each do |q|
                q.filter_responses(params[:user_id],
                params[:branch_id],DateTime.parse(params[:date_filter][:start]))
              end
            end
          else
            @report.pages.each do |p|
              p.questions.each do |q|
                q.filtered_responses = q.responses
              end
            end
          end
          if params[:type] = "csv"
            response_json = create_csv(@report)
            
          end
          render json: {data: response_json},status: :ok
          # render csv: {data: response_json},status: :ok
          # send_data(response_json,
          #   :type => 'text/csv; charset=utf-8;',
          #   :filename => "myfile.csv")
        rescue => invalid
          logger.error invalid
          render json: {error: "Problem exporting report"},
            status: :internal_server_errir
        end
      end

      private
        def report_params
          params.permit(:title,:description,pages_attributes: [:title,questions_attributes: [:question_type,:title,skus: [],options: []]])
        end

        def response_params(raw_params)
          params = ActionController::Parameters.new(raw_params)
          params.permit(:question_id,:question_type,:single_resp,:bool_resp,:image_resp,multiple_resp:[])
        end

        def branch_response_params(id)
          raw_params = {response_id: id}
          params = ActionController::Parameters.new(raw_params)
          params.permit(:response_id)
        end

        def user_report_params(r_id,b_id)
          raw_params = {report_id: r_id,branch_id: b_id}
          params = ActionController::Parameters.new(raw_params)
          params.permit(:report_id,:branch_id)
        end

        def decode_image(res)
          image_params = res[:single_resp]
          file_name = "responseImage.jpeg"
          @tmp_file = Tempfile.new("fileupload")
          @tmp_file.binmode
          @tmp_file.write(Base64.decode64(image_params))
          uploaded_file =
            ActionDispatch::Http::UploadedFile.new(:tempfile => @tmp_file,:filename => file_name,:original_filename => file_name,:content_type => "image/jpeg",)
          res[:single_resp] = nil
          res[:image_resp] = uploaded_file
        end

        def clean_tmp_file
          if @tmp_file
            @tmp_file.close
            @tmp_file.unlink
          end
        end
    end
  end
end
