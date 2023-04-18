class LmChannelValue < ApplicationRecord
  belongs_to :lm_channel

  after_create_commit do
    broadcast_prepend_to "lm_channel_values_#{lm_channel.id}", target: "lm_channel_values", partial: "lm_channel_values/lm_channel_value", locals: { lm_channel_value: self }
  end
end
