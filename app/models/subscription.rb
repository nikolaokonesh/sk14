class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :followable, polymorphic: true, counter_cache: :followers_count

  validates :user_id, uniqueness: { scope: [ :followable_id, :followable_type ] }
end
