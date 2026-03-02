class EntryReadState < ApplicationRecord
  broadcasts_refreshes_to :entry

  belongs_to :user, touch: true
  belongs_to :entry, touch: true

  validates :entry_id, uniqueness: { scope: :user_id }
end
