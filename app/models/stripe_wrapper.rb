module StripeWrapper
  class Charge
    attr_reader :error_message, :stripe_response

    def initialize(options={})
      @stripe_response = options[:stripe_response]
      @error_message = options[:error_message]
    end

    def self.create(options={})
      begin
        stripe_response = Stripe::Charge.create(
          source: options[:source],
          amount: options[:amount],
          description: options[:description],
          currency: 'usd'
          )
        new(stripe_response: stripe_response)
      rescue Stripe::CardError => e
        new(error_message: e.message)
      end
    end

    def successful?
      stripe_response.present?
    end
  end
end