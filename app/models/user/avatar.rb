class User::Avatar < ApplicationRecord
  # supported options: :image, :audio, :video, :text
  validates :avatar, blob: { content_type: :image, size_range: 1..5.megabytes }

  has_one_attached :avatar do |attachable|
    # добавь это в конец "immediate: true" вместо preprocessed
    attachable.variant :thumbnail, resize_to_fill: [ 200, 200 ], preprocessed: true
  end

  belongs_to :user, touch: true
end
