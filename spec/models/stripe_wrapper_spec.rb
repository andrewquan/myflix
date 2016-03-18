require 'spec_helper'

describe "StripeWrapper" do
  let(:valid_card_token) do
    Stripe::Token.create(
      :card => {
        number: "4242424242424242",
        exp_month: 2,
        exp_year: 2020,
        cvc: "314"
      },
    ).id
  end

  let(:declined_card_token) do
    Stripe::Token.create(
      :card => {
        number: "4000000000000002",
        exp_month: 2,
        exp_year: 2020,
        cvc: "314"
      },
    ).id
  end

  describe "StripeWrapper::Charge" do
    describe ".create" do
      it "makes a successful charge", :vcr do
        stripe_response = StripeWrapper::Charge.create(
          source: valid_card_token,
          amount: 999,
          description: 'MyFlix sign up charge'
        )

        expect(stripe_response).to be_successful
      end

      it "makes a declined card charge", :vcr do
        stripe_response = StripeWrapper::Charge.create(
          source: declined_card_token,
          amount: 999,
          description: 'invalid MyFlix sign up charge'
        )

        expect(stripe_response).not_to be_successful
      end

      it "returns the error message for declined card charges", :vcr do
        stripe_response = StripeWrapper::Charge.create(
          source: declined_card_token,
          amount: 999,
          description: 'invalid MyFlix sign up charge'
        )

        expect(stripe_response.error_message).to eq("Your card was declined.")
      end
    end
  end

  describe "Stripe::Customer" do
    describe ".create" do
      it "creates a customer with a valid card", :vcr do
        alice = Fabricate(:user)
        stripe_response = StripeWrapper::Customer.create(
          email: alice.email,
          source: valid_card_token
          )
        expect(stripe_response).to be_successful
      end

      it "does not create a customer with an invalid card", :vcr do
        alice = Fabricate(:user)
        stripe_response = StripeWrapper::Customer.create(
          email: alice.email,
          source: declined_card_token
          )
        expect(stripe_response).not_to be_successful
      end

      it "returns the error message for declined card charges", :vcr do
        alice = Fabricate(:user)
        stripe_response = StripeWrapper::Customer.create(
          email: alice.email,
          source: declined_card_token
          )
        expect(stripe_response.error_message).to eq("Your card was declined.")
      end
    end
  end
end