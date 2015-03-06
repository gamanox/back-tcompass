module SessionsHelper
   #TODO: rescue when token is nil
   def current_user
     if params[:token]
       @current_user ||= User.where(token: params[:token],is_active: true).first
     else
       @current_user ||= User.where(token: request.headers['Authorization'],is_active: true).first
     end
  end
end
