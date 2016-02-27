class ForgotPasswordsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:email])

    if user
      user.generate_token
      AppMailer.delay.send_forgot_password(user.id)
      redirect_to forgot_password_confirmation_path
    else
      flash[:danger] = params[:email].blank? ? "Email cannot be blank." : "No account is associated with that email address. Please try again."
      redirect_to forgot_password_path
    end
  end

  def confirm
  end
end