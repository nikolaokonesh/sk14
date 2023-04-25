class LmChannel < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  validates :name, uniqueness: true
  has_many :lm_channel_values

  broadcasts_to ->(lm_channel) { :lm_channels }

  after_create_commit do
    broadcast_append_to "lm_channels", target: "lm_channel_#{self.prefix}", partial: "lm_channels/lm_channel", locals: { lm_channel: self }
  end
end
