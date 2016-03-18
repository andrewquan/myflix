require 'spec_helper'

describe UserSignup do
  describe "#sign_up" do
    context "valid personal info and valid card info" do
      let(:customer) { double(:customer, successful?: true) }
      
      before do
        expect(StripeWrapper::Customer).to receive(:create).and_return(customer)
      end

      it "creates the user" do
        UserSignup.new(Fabricate.build(:user)).sign_up('12345', nil)
        expect(User.count).to eq(1)
      end

      it "makes the user follow the inviter" do
        alice = Fabricate(:user)
        invitation = Fabricate(:invitation, inviter: alice, recipient_email: 'bob@example.com')
        UserSignup.new(Fabricate.build(:user, email: 'bob@example.com', password: 'password', full_name: 'Bob Dylan')).sign_up('12345', invitation.token)
        bob = User.find_by(email: 'bob@example.com')
        expect(bob.follows?(alice)).to be true
      end

      it "makes the inviter follow the user" do
        alice = Fabricate(:user)
        invitation = Fabricate(:invitation, inviter: alice, recipient_email: 'bob@example.com')
        UserSignup.new(Fabricate.build(:user, email: 'bob@example.com', password: 'password', full_name: 'Bob Dylan')).sign_up('12345', invitation.token)
        bob = User.find_by(email: 'bob@example.com')
        expect(alice.follows?(bob)).to be true
      end

      it "expires the invitation after acceptance" do
        alice = Fabricate(:user)
        invitation = Fabricate(:invitation, inviter: alice, recipient_email: 'bob@example.com')
        UserSignup.new(Fabricate.build(:user, email: 'bob@example.com', password: 'password', full_name: 'Bob Dylan')).sign_up('12345', invitation.token)
        expect(invitation.reload.token).to be_nil
      end
    end

    context "with valid personal info and declined card" do
      it "does not create the user" do
        customer = double(:customer, successful?: false, error_message: "Your card was declined.")
        expect(StripeWrapper::Customer).to receive(:create).and_return(customer)
        UserSignup.new(Fabricate.build(:user)).sign_up('12345', nil)
        expect(User.count).to eq(0)
      end
    end

    context "with invalid input" do
      it "does not create the user" do
        UserSignup.new(User.new(email: Faker::Internet.email, password: 'password')).sign_up('12345', nil)
        expect(User.count).to eq(0)
      end

      it "does not charge the card" do
        expect(StripeWrapper::Customer).not_to receive(:create)
        UserSignup.new(User.new(email: "john@example.com")).sign_up('12345', nil)
      end

      it "does not send an email" do
        ActionMailer::Base.deliveries.clear
        UserSignup.new(User.new(email: 'john@example.com')).sign_up('12345', nil)
        expect(ActionMailer::Base.deliveries).to be_empty
      end
    end

    context "sending emails" do
      let(:customer) { double(:customer, successful?: true) }

      before do
        expect(StripeWrapper::Customer).to receive(:create).and_return(customer)
      end

      after { ActionMailer::Base.deliveries.clear }

      it "sends an email to the user with valid inputs" do
        UserSignup.new(Fabricate.build(:user, email: 'john@example.com')).sign_up('12345', nil)
        expect(ActionMailer::Base.deliveries.last.to).to eq(['john@example.com'])
      end

      it "sends an email with the user's name with valid inputs" do
        UserSignup.new(Fabricate.build(:user, email: 'john@example.com', password: 'password', full_name: 'John Doe')).sign_up('12345', nil)
        expect(ActionMailer::Base.deliveries.last.body).to include('John Doe')
      end
    end
  end
end