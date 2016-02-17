class UsersController < ApplicationController
  before_filter :require_user, only: [:show]

  def new
    @user = User.new
    if current_user
      flash[:notice] = "Please sign out in order to register a new user."
      redirect_to home_path
    end
  end

  def create
    @user = User.new(user_params)

    if @user.valid?
      @amount = 999
      charge = StripeWrapper::Charge.create(
        source: params[:stripeToken],
        amount: @amount,
        description: 'MyFlix sign up charge',
      )
      if charge.successful?
        @user.save
        handle_invitation
        AppMailer.delay.send_welcome_email(@user.id)
        flash[:notice] = "You're now registered!"
        redirect_to sign_in_path
      else
        flash[:danger] = charge.error_message
        render :new
      end
    else
      flash[:danger] = "Invalid personal information. Please check the errors below."
      render :new
    end
  end

  def show
    @user = User.find(params[:id])
  end

  def new_with_invitation_token
    invitation = Invitation.find_by(token: params[:token])
    if invitation
      @user = User.new(email: invitation.recipient_email)
      @invitation_token = invitation.token
      render :new
    else
      redirect_to expired_token_path
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :full_name)
  end

  def handle_invitation
    if params[:invitation_token].present?
      invitation = Invitation.find_by(token: params[:invitation_token])
      @user.follow(invitation.inviter)
      invitation.inviter.follow(@user)
      invitation.update_column(:token, nil)
    end
  end
end