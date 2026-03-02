class EntryReadState < ApplicationRecord
  belongs_to :user, touch: true
  belongs_to :entry, touch: true

  validates :entry_id, uniqueness: { scope: :user_id }
end
