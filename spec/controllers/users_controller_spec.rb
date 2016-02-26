require 'spec_helper'

describe UsersController do
  describe "GET new" do
    it "sets @user" do
      get :new
      expect(assigns(:user)).to be_instance_of(User)
    end

    it "sets flash notice if current user" do
      set_current_user
      get :new
      expect(flash[:notice]).to be_present
    end

    it "redirects to the home page if logged in" do
      set_current_user
      get :new
      expect(response).to redirect_to home_path
    end
  end

  describe "POST create" do
    context "successful user sign up" do
      it "redirects to sign_in_path" do
        result = double(:sign_up_result, successful?: true)
        expect_any_instance_of(UserSignup).to receive(:sign_up).and_return(result)
        post :create, user: Fabricate.attributes_for(:user)
        expect(response).to redirect_to sign_in_path
      end
    end

    context "unsuccessful user sign up" do
      it "renders the new template" do
        result = double(:sign_up_result, successful?: false, error_message: "Your card was declined.")
        expect_any_instance_of(UserSignup).to receive(:sign_up).and_return(result)
        post :create, user: Fabricate.attributes_for(:user), stripeToken: '12345'
        expect(response).to render_template :new
      end

      it "sets the flash danger notice" do
        result = double(:sign_up_result, successful?: false, error_message: "Your card was declined.")
        expect_any_instance_of(UserSignup).to receive(:sign_up).and_return(result)
        post :create, user: Fabricate.attributes_for(:user), stripeToken: '12345'
        expect(flash[:danger]).to eq("Your card was declined.")
      end
    end
  end

  describe "GET show" do
    it "sets @user" do
      set_current_user
      alice = Fabricate(:user)
      get :show, id: alice.id
      expect(assigns(:user)).to eq(alice)
    end

    it_behaves_like "requires sign in" do
      let(:action) { get :show, id: Fabricate(:user).id }
    end
  end

  describe "GET new_with_invitation_token" do
    context "with valid token" do
      let(:invitation) { Fabricate(:invitation) }
      before { get :new_with_invitation_token, token: invitation.token }

      it "renders :new user template" do
        expect(response).to render_template :new
      end

      it "sets @user with recipient's email" do
        expect(assigns(:user).email).to eq(invitation.recipient_email)
      end

      it "sets @invitation_token" do
        expect(assigns(:invitation_token)).to eq(invitation.token)
      end
    end

    context "with invalid token" do
      it "redirects to expired token page for invalid tokens" do
        get :new_with_invitation_token, token: 'invalidtoken'
        expect(response).to redirect_to expired_token_path
      end
    end
  end
end