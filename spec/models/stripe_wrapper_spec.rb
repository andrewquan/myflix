require 'spec_helper'

describe "StripeWrapper" do
  describe "StripeWrapper::Charge" do
    describe ".create" do
      it "makes a successful charge", :vcr do
        token = Stripe::Token.create(
          :card => {
            number: "4242424242424242",
            exp_month: 2,
            exp_year: 2020,
            cvc: "314"
          },
        ).id

        stripe_response = StripeWrapper::Charge.create(
          source: token,
          amount: 999,
          description: 'MyFlix sign up charge'
        )

        expect(stripe_response).to be_successful
      end

      it "makes a declined card charge", :vcr do
        token = Stripe::Token.create(
          :card => {
            number: "4000000000000002",
            exp_month: 2,
            exp_year: 2020,
            cvc: "314"
          },
        ).id

        stripe_response = StripeWrapper::Charge.create(
          source: token,
          amount: 999,
          description: 'invalid MyFlix sign up charge'
        )

        expect(stripe_response).not_to be_successful
      end

      it "returns the error message for declined card charges", :vcr do
        token = Stripe::Token.create(
          :card => {
            number: "4000000000000002",
            exp_month: 2,
            exp_year: 2020,
            cvc: "314"
          },
        ).id

        stripe_response = StripeWrapper::Charge.create(
          source: token,
          amount: 999,
          description: 'invalid MyFlix sign up charge'
        )

        expect(stripe_response.error_message).to eq("Your card was declined.")
      end
    end
  end
end