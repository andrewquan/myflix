require 'spec_helper'

describe UsersController do
  describe "GET new" do
    it "sets @user" do
      get :new
      expect(assigns(:user)).to be_instance_of(User)
    end
  end

  describe "POST create" do
    context "with valid input" do
      before do
        post :create, user: Fabricate.attributes_for(:user)
      end

      it "creates the user" do
        expect(User.count).to eq(1)
      end

      it "redirects to sign_in_path" do
        expect(response).to redirect_to sign_in_path
      end
    end

    context "with invalid input" do
      before do
        post :create, user: { email: Faker::Internet.email, password: 'password' }
      end

      it "does not create the user" do
        expect(User.count).to eq(0)
      end

      it "renders the new template" do
        expect(response).to render_template :new
      end

      it "sets @user" do
        expect(assigns(:user)).to be_instance_of(User)
      end
    end

    context "sending emails" do
      after { ActionMailer::Base.deliveries.clear }

      it "sends an email to the user with valid inputs" do
        post :create, user: {email: 'john@example.com', password: 'password', full_name: 'John Doe'}
        expect(ActionMailer::Base.deliveries.last.to).to eq(['john@example.com'])
      end

      it "sends an email with the user's name with valid inputs" do
        post :create, user: {email: 'john@example.com', password: 'password', full_name: 'John Doe'}
        expect(ActionMailer::Base.deliveries.last.body).to include('John Doe')
      end

      it "does not send an email with invalid inputs" do
        post :create, user: {email: 'john@example.com'}
        expect(ActionMailer::Base.deliveries).to be_empty
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
end