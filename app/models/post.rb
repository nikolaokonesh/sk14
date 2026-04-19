class Post < ApplicationRecord
  broadcasts_refreshes
  include FirstImage
  has_one :entry, as: :entryable, touch: true, dependent: :destroy

  has_delegated_json :setting, no_comments: false
end
