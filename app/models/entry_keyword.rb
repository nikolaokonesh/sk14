class EntryKeyword < ApplicationRecord
  belongs_to :entry, touch: true
  belongs_to :tag, touch: true

  validates :keyword, presence: true
  validates :entry, uniqueness: { scope: :keyword }
end
