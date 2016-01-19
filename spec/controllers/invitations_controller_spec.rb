require 'spec_helper'

describe InvitationsController do
  describe "GET new" do
    it "sets @invitations to a new invitation" do
      set_current_user
      get :new
      expect(assigns(:invitation)).to be_new_record
      expect(assigns(:invitation)).to be_instance_of(Invitation)
    end
    
    it_behaves_like "requires sign in" do
      let(:action) { get :new }
    end
  end

  describe "POST create" do
    after { ActionMailer::Base.deliveries.clear }

    context "with valid inputs" do
      it "redirects to the new invitation page" do
        set_current_user
        post :create, invitation: {recipient_name: "Bob", recipient_email: 'bob@example.com', message: 'Please join MyFlix!' }
        expect(response).to redirect_to new_invitation_path
      end

      it "creates a new invitation" do
        set_current_user
        post :create, invitation: {recipient_name: "Bob", recipient_email: 'bob@example.com', message: 'Please join MyFlix!' }
        expect(Invitation.count).to eq(1)
      end

      it "sends an email to the recipient" do
        set_current_user
        post :create, invitation: {recipient_name: "Bob", recipient_email: 'bob@example.com', message: 'Please join MyFlix!' }
        expect(ActionMailer::Base.deliveries.last.to).to eq(['bob@example.com'])
      end

      it "sets the flash success" do
        set_current_user
        post :create, invitation: {recipient_name: "Bob", recipient_email: 'bob@example.com', message: 'Please join MyFlix!' }
        expect(flash[:success]).to be_present
      end
    end

    context "with invalid inputs" do
      after { ActionMailer::Base.deliveries.clear }
      it "renders the new template" do
        set_current_user
        post :create, invitation: {recipient_name: "Bob"}
        expect(response).to render_template :new
      end

      it "sets @invitation" do
        set_current_user
        post :create, invitation: {recipient_name: "Bob"}
        expect(assigns(:invitation)).to be_instance_of(Invitation)
      end

      it "does not create an invitation" do
        set_current_user
        post :create, invitation: {recipient_name: "Bob"}
        expect(Invitation.count).to eq(0)
      end

      it "does not send an email" do
        set_current_user
        post :create, invitation: {recipient_name: "Bob"}
        expect(ActionMailer::Base.deliveries.count).to eq(0)
      end

      it "sets the flash error" do
        set_current_user
        post :create, invitation: {recipient_name: "Bob"}
        expect(flash[:error]).to be_present
      end
    end

    it_behaves_like "requires sign in" do
      let(:action) { post :create }
    end
  end
end