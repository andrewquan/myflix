require 'spec_helper'

describe SessionsController do
  describe "GET new" do
    it "renders the new template for unauthenticated users" do
      get :new
      expect(response).to render_template :new
    end

    it "redirects to the home path for authenticated users" do
      set_current_user
      get :new
      expect(response).to redirect_to home_path
    end
  end

  describe "POST create" do
    let(:alice) { Fabricate(:user) }

    context "for valid credentials" do
      before do
        post :create, email: alice.email, password: alice.password
      end

      it "puts the signed in user in the session" do
        expect(session[:user_id]).to eq(alice.id)
      end

      it "redirects to the home path" do
        expect(response).to redirect_to home_path
      end

      it "gives a flash notice" do
        expect(flash[:notice]).not_to be_blank
      end
    end

    context "for invalid credentials" do
      before do
        post :create, email: alice.email, password: "#{alice.password}plusextrastuff"
      end

      it "does not set the session" do
        expect(session[:user_id]).to be_nil
      end

      it "redirects to the sign_in_path" do
        expect(response).to redirect_to sign_in_path
      end

      it "gives a flash error notice" do
        expect(flash[:error]).not_to be_blank
      end
    end
  end

  describe "GET destroy" do
    before do
      set_current_user
      get :destroy
    end

    it "sets the session to nil" do
      expect(session[:user_id]).to be_nil
    end

    it "redirects to the root path" do
      expect(response).to redirect_to root_path
    end

    it "gives a flash notice" do
      expect(flash[:notice]).not_to be_blank
    end
  end
end