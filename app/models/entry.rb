class Entry < ApplicationRecord
  POST_TYPE = "Post".freeze
  COMMENT_TYPE = "Comment".freeze
  AUTO_SERVICE_TYPE = "AutoService".freeze
  TITLE_PREVIEW_LENGTH = 500

  include CommentsCounter
  include Reactions
  include Threading
  include ContentTitle

  delegated_type :entryable, types: [ POST_TYPE, COMMENT_TYPE, AUTO_SERVICE_TYPE ], dependent: :destroy
  delegate :content, to: :entryable, allow_nil: true
  accepts_nested_attributes_for :entryable

  scope :recent, -> { order(created_at: :desc) }
  scope :active, -> { where(trash: false) }
  scope :inactive, -> { where(trash: true) }

  # Иерархия
  belongs_to :user, touch: true
  belongs_to :parent, class_name: "Entry", optional: true
  belongs_to :root, class_name: "Entry", optional: true

  has_many :replies, class_name: "Entry", foreign_key: :parent_id, dependent: :destroy
  has_many :descendants, class_name: "Entry", foreign_key: :root_id, dependent: :destroy

  has_many :comments, -> { where(entryable_type: COMMENT_TYPE) },
           class_name: "Entry", foreign_key: :root_id, dependent: :destroy

  has_many :entry_keywords, dependent: :destroy
  has_many :tags, through: :entry_keywords

  has_many :reactions, dependent: :destroy
  has_many :noticed_events, as: :record, class_name: "Noticed::Event", dependent: :destroy
  has_many :notifications, through: :noticed_events, class_name: "Noticed::Notification", dependent: :destroy
  has_many :entry_read_states, dependent: :destroy

  validates :title, length: { maximum: 200 }, allow_blank: true
end
