class UserSignup
  attr_reader :error_message

  def initialize(user)
    @user = user
  end

  def sign_up(stripe_token, invitation_token=nil)
    if @user.valid?
      customer = StripeWrapper::Customer.create(
        source: stripe_token,
        email: @user.email
      )
      if customer.successful?
        @user.save
        handle_invitation(invitation_token)
        AppMailer.delay.send_welcome_email(@user.id)
        @status = :success
      else
        @status = :failed
        @error_message = customer.error_message
      end
    else
      @status = :failed
      @error_message = "Invalid personal information. Please check the errors below."
    end
    self
  end

  def successful?
    @status == :success
  end

  private

  def handle_invitation(invitation_token)
    if invitation_token.present?
      invitation = Invitation.find_by(token: invitation_token)
      @user.follow(invitation.inviter)
      invitation.inviter.follow(@user)
      invitation.update_column(:token, nil)
    end
  end
end