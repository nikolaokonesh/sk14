class LmChannel < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  validates :name, uniqueness: true
  has_many :lm_channel_values
end
