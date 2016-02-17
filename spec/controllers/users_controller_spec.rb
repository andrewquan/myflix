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
    context "with valid personal info and valid card info" do
      let(:charge) { double(:charge, successful?: true) }
      before do
        expect(StripeWrapper::Charge).to receive(:create).and_return(charge)
      end

      it "creates the user" do
        post :create, user: Fabricate.attributes_for(:user)
        expect(User.count).to eq(1)
      end

      it "redirects to sign_in_path" do
        post :create, user: Fabricate.attributes_for(:user)
        expect(response).to redirect_to sign_in_path
      end

      it "makes the user follow the inviter" do
        alice = Fabricate(:user)
        invitation = Fabricate(:invitation, inviter: alice, recipient_email: 'bob@example.com')
        post :create, user: {email: 'bob@example.com', password: 'password', full_name: 'Bob Dylan'}, invitation_token: invitation.token
        bob = User.find_by(email: 'bob@example.com')
        expect(bob.follows?(alice)).to be true
      end

      it "makes the inviter follow the user" do
        alice = Fabricate(:user)
        invitation = Fabricate(:invitation, inviter: alice, recipient_email: 'bob@example.com')
        post :create, user: {email: 'bob@example.com', password: 'password', full_name: 'Bob Dylan'}, invitation_token: invitation.token
        bob = User.find_by(email: 'bob@example.com')
        expect(alice.follows?(bob)).to be true
      end

      it "expires the invitation after acceptance" do
        alice = Fabricate(:user)
        invitation = Fabricate(:invitation, inviter: alice, recipient_email: 'bob@example.com')
        post :create, user: {email: 'bob@example.com', password: 'password', full_name: 'Bob Dylan'}, invitation_token: invitation.token
        expect(invitation.reload.token).to be_nil
      end
    end

    context "with valid personal info and declined card" do
      it "does not create the user" do
        charge = double(:charge, successful?: false, error_message: "Your card was declined.")
        expect(StripeWrapper::Charge).to receive(:create).and_return(charge)
        post :create, user: Fabricate.attributes_for(:user), stripeToken: '12345'
        expect(User.count).to eq(0)
      end
      
      it "renders the new template" do
        charge = double(:charge, successful?: false, error_message: "Your card was declined.")
        expect(StripeWrapper::Charge).to receive(:create).and_return(charge)
        post :create, user: Fabricate.attributes_for(:user), stripeToken: '12345'
        expect(response).to render_template :new
      end

      it "sets the flash danger notice" do
        charge = double(:charge, successful?: false, error_message: "Your card was declined.")
        expect(StripeWrapper::Charge).to receive(:create).and_return(charge)
        post :create, user: Fabricate.attributes_for(:user), stripeToken: '12345'
        expect(flash[:danger]).to be_present
      end
    end

    context "with invalid input" do
      it "does not create the user" do
        post :create, user: { email: Faker::Internet.email, password: 'password' }
        expect(User.count).to eq(0)
      end

      it "renders the new template" do
        post :create, user: { email: Faker::Internet.email, password: 'password' }
        expect(response).to render_template :new
      end

      it "sets @user" do
        post :create, user: { email: Faker::Internet.email, password: 'password' }
        expect(assigns(:user)).to be_instance_of(User)
      end

      it "does not charge the card" do
        expect(StripeWrapper::Charge).not_to receive(:create)
        post :create, user: { email: "john@example.com" }
      end

      it "does not send an email" do
        post :create, user: {email: 'john@example.com'}
        expect(ActionMailer::Base.deliveries).to be_empty
        ActionMailer::Base.deliveries.clear
      end
    end

    context "sending emails" do
      let(:charge) { double(:charge, successful?: true) }
      before do
        expect(StripeWrapper::Charge).to receive(:create).and_return(charge)
      end

      after { ActionMailer::Base.deliveries.clear }

      it "sends an email to the user with valid inputs" do
        post :create, user: {email: 'john@example.com', password: 'password', full_name: 'John Doe'}
        expect(ActionMailer::Base.deliveries.last.to).to eq(['john@example.com'])
      end

      it "sends an email with the user's name with valid inputs" do
        post :create, user: {email: 'john@example.com', password: 'password', full_name: 'John Doe'}
        expect(ActionMailer::Base.deliveries.last.body).to include('John Doe')
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