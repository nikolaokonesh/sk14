# frozen_string_literal: true

class Post < ApplicationRecord
  broadcasts_refreshes

  include Afisha
  include SettingsCleanup

  DURATION_VARIANTS = Post::Afisha::DURATION_VARIANTS
  TAG_CONFIG = Post::SettingsCleanup::TAG_CONFIG

  has_one :entry, as: :entryable, touch: true, dependent: :destroy

  has_delegated_json :setting,
                     no_comments: false,
                     duration: "forever"

  has_delegated_json :tags_listing,
                     urgent: false, important: false, event: false,
                     question: false, sell: false, buy: false, help: false
end
