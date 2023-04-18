class LmChannel < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  validates :name, uniqueness: true
  has_many :lm_channel_values

  broadcasts_to ->(lm_channel) { :lm_channels }
end
