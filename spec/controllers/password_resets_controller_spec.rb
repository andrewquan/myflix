require 'spec_helper'

describe PasswordResetsController do
  describe "GET show" do
    it "renders the show template if the token is valid" do
      alice = Fabricate(:user)
      alice.generate_token
      get :show, id: alice.token
      expect(response).to render_template :show
    end

    it "sets @token" do
      alice = Fabricate(:user)
      alice.generate_token
      get :show, id: alice.token
      expect(assigns(:token)).to eq(alice.token)
    end

    it "redirects to the expired token page if the token is invalid" do
      get :show, id: '12345'
      expect(response).to redirect_to expired_token_path
    end
  end

  describe "POST create" do
    context "with valid token" do
      let(:alice) { alice = Fabricate(:user, password: 'password') }
      before { 
        alice.generate_token
        post :create, token: alice.token, password: 'new_password'
      }

      it "updates the user's password" do
        expect(alice.reload.authenticate('new_password')).to be_truthy
      end

      it "redirects to the sign in page" do
        expect(response).to redirect_to sign_in_path
      end

      it "sets the flash success" do
        expect(flash[:success]).not_to be_blank
      end

      it "removes the user's token" do
        expect(alice.reload.token).to be_nil
      end
    end

    context "with invalid token" do
      it "redirects to the expired token page" do
        post :create, token: '12345', password: 'new_password'
        expect(response).to redirect_to expired_token_path
      end
    end
  end
end