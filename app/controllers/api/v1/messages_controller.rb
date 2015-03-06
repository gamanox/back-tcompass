module Api
  module V1
    class MessagesController < ApplicationController
      respond_to :json

      def index
        begin
          if params[:group_id]
            @messages = Message.for(current_user,params[:group_id])
          else
            @messages = Message.for(current_user)
          end
          respond_with @messages,each_serializer: MessageSerializer
        rescue => invalid
          logger.error invalid
          render json: {error:"Problem retrieving messages"},
            status: :internal_server_error
        end
      end

      def create
        begin
          @message = current_user.messages.create!(message_params)
          @message.assign_groups(params[:groups_ids])
          redirect_url = "/api/comments/#{@message.id}"
          render json:{
            url: redirect_url
            },status: :ok
        rescue ActiveRecord::RecordNotFound => invalid
          logger.error invalid
          render json: {error: "Problem creating message"},
            status: :internal_server_error
        rescue => invalid
          logger.error invalid
          render json: {error:"Problem creating message"},
            status: :internal_server_error
        end
      end

      def show
        begin
          @message = Message.find(params[:id])
          @message.is_read?(current_user.id)
          respond_with @message, serializer: MessageSerializer
        rescue ActiveRecord::RecordNotFound => invalid
          logger.error invalid
          render json: {error: "Couldn't find Message with 'id'=#{params[:id]}"},
            status: :not_found
        rescue => invalid
          logger.error invalid
          render json: {error:"Message not found"},status: :not_found
        end
      end

      #TODO: refactor to use the right methods
      def comment
        begin
          @message = Message.find(params[:id])
          @comment = current_user.messages.new(comment_params)
          @comment.comment_id = @message.id
          @comment.save!
          redirect_url =
            "/api/comments/#{@message.id}"
          render json:{
            url: redirect_url
            },status: :ok
        rescue ActiveRecord::RecordInvalid => invalid
          logger.error invalid
          render json: {error: "Problem creating comment"},
            status: :internal_server_error
        rescue ActiveRecord::RecordNotFound => invalid
          logger.error invalid
          render json: {error: "Couldn't find Message."}
        rescue => invalid
          logger.error invalid
          render json: {error: "Problem creating comment"}, status: :internal_server_error
        end
      end

      def destroy
        begin
          current_user.messages.find(params[:id]).destroy
          render json: {message: "Message deleted"},status: :ok
        rescue ActiveRecord::RecordNotFound => invalid
          logger.error invalid
          render json: {error: "Message not found"}
        rescue => invalid
          logger.error invalid
          render json: {error: "There was a problem deleting the message"},
            status: :internal_server_error
        end
      end

      def read
        begin
          current_user.read_message(params[:id])
          render json: {message: "Message read"},status: :ok
        rescue ActiveRecord::RecordNotFound => invalid
          logger.error invalid
          render json: {error: "Message not found"},status: :not_found
        rescue => invalid
          logger.error invalid
          render json: {error: "There was a problem reading the message"},
          status: :internal_server_error
        end
      end

      private
        def message_params
          params.require(:message).permit(:title,:content)
        end

        def comment_params
          params.require(:message).permit(:content)
        end
    end
  end
end
