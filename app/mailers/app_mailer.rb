class AppMailer < ActionMailer::Base
  def send_welcome_email(user_id)
    @user = User.find(user_id)
    mail to: @user.email, from: "info@myflix.com", subject: "Welcome to MyFlix!"
  end

  def send_forgot_password(user_id)
    @user = User.find(user_id)
    mail to: @user.email, from: "info@myflix.com", subject: "Reset password"
  end

  def send_invitation_email(invitation_id)
    @invitation = Invitation.find(invitation_id)
    mail to: @invitation.recipient_email, from: "info@myflix.com", subject: "Join MyFlix today!"
  end
end