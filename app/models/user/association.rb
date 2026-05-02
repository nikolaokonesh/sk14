module User::Association
  extend ActiveSupport::Concern

  included do
    has_many :sessions, dependent: :destroy
    has_many :access_tokens, dependent: :destroy

    has_many :entries, dependent: :destroy
    has_many :posts, through: :entries, source: :entryable, source_type: "Post"

    has_many :notifications, as: :recipient, class_name: "Noticed::Notification", dependent: :destroy

    has_many :entry_reads, dependent: :destroy
    has_many :advertisements, dependent: :destroy
  end
end
