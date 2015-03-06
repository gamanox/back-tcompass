class UserMailer < ActionMailer::Base
  default from: "noreply@teamcompass.mx"

  def welcome_email(user,password)
    @user = user
    @password = password
    mail(to: @user.email,subject: 'Bienvenido a TeamCompass')
  end
end
