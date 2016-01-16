require 'spec_helper'

describe ForgotPasswordsController do
  describe "POST create" do
    context "with blank input" do
      it "redirects to the forgot password page" do
        post :create, email: ""
        expect(response).to redirect_to forgot_password_path
      end

      it "sets the flash error" do
        post :create, email: ""
        expect(flash[:error]).to eq("Email cannot be blank.")
      end
    end

    context "with existing email" do
      it "redirects to the forgot password confirmation page" do
        Fabricate(:user, email: "john@example.com")
        post :create, email: "john@example.com"
        expect(response).to redirect_to forgot_password_confirmation_path
      end

      it "sends out an email to the email address" do
        Fabricate(:user, email: "john@example.com")
        post :create, email: "john@example.com"
        expect(ActionMailer::Base.deliveries.last.to).to eq(['john@example.com'])
      end

      it "generates a token for the user" do
        john = Fabricate(:user, email: "john@example.com")
        post :create, email: "john@example.com"
        expect(john.reload.token).to be_present
      end
    end

    context "with non-existing email" do
      it "redirects to the forgot password page" do
        post :create, email: "john@example.com"
        expect(response).to redirect_to forgot_password_path
      end

      it "sets the flash error" do
        post :create, email: "john@example.com"
        expect(flash[:error]).to eq("No account is associated with that email address. Please try again.")
      end
    end
  end
end