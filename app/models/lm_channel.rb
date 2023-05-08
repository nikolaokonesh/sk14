class LmChannel < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  validates :name, uniqueness: true
  has_many :lm_channel_values

  after_create_commit do
    broadcast_append_to "lm_channels", target: "lm_block_#{self.prefix}", partial: "lm_channels/lm_channel", locals: { lm_channel: self }
  end

  after_update_commit do
    broadcast_update_to "lm_channels", target: "lm_channel_#{self.id}", partial: "lm_channels/lm_channel", locals: { lm_channel: self }
  end

  after_commit :last_update_channel, on: [ :update ]
  def last_update_channel
    broadcast_update_to('lm_channels', target: 'last_update_channel', partial: "lm_channels/last_update_channel", locals: { last_update_channel: LmChannel.order(:updated_at).last.updated_at })
  end
end
