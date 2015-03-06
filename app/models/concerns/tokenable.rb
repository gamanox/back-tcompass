module Tokenable
  extend ActiveSupport::Concern

  included do
    before_create :generate_token
  end

  protected

  def generate_token
    self.token = loop do
      random_token = SecureRandom.hex(16)
      break random_token unless self.class.exists?(token: random_token)
    end
  end
end
