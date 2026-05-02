class Post < ApplicationRecord
  broadcasts_refreshes
  include Afisha
  include SettingsCleanup

  has_one :entry, as: :entryable, touch: true, dependent: :destroy

  DURATION_VARIANTS = Post::Afisha::DURATION_VARIANTS
  TAG_CONFIG = Post::SettingsCleanup::TAG_CONFIG

  has_delegated_json :setting,
                     no_comments: false,
                     duration: "forever"

  # Теги остаются в JSON (это удобно)
  has_delegated_json :tags_listing,
                     urgent: false, important: false, event: false,
                     question: false, sell: false, buy: false, help: false
end
