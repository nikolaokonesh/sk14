# frozen_string_literal: true

class AccessToken < ApplicationRecord
  TOKEN_LENGTH = 32

  belongs_to :user

  before_create :set_token

  validates :token, uniqueness: { case_sensitive: false }

  private

  def set_token
    self.token = generate_unique_token
  end

  def generate_unique_token
    loop do
      candidate = SecureRandom.hex(TOKEN_LENGTH)
      return candidate unless self.class.exists?(token: candidate)
    end
  end
end
