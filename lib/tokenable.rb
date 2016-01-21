module Tokenable
  extend ActiveSupport::Concern

  def generate_token
    self.update_column(:token, SecureRandom.urlsafe_base64)
  end
end