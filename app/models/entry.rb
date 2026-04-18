class Entry < ApplicationRecord
  broadcasts_refreshes

  POST_TYPE = "Post".freeze

  delegated_type :entryable, types: [ POST_TYPE ], dependent: :destroy
  delegate :content, to: :entryable, allow_nil: true
  accepts_nested_attributes_for :entryable

  before_validation :set_root_from_parent, if: :parent_id?
  after_create :set_self_as_root, unless: :root_id?
  validate :root_consistency, on: :update, if: :root_id_changed?

  scope :recent, -> { order(created_at: :desc) }
  scope :active, -> { where(trash: false) }
  scope :inactive, -> { where(trash: true) }

  # Иерархия
  belongs_to :user, touch: true
  belongs_to :parent, class_name: "Entry", optional: true
  belongs_to :root, class_name: "Entry", optional: true

  has_many :replies, class_name: "Entry", foreign_key: :parent_id
  has_many :descendants, class_name: "Entry", foreign_key: :root_id

  has_many :noticed_events, as: :record, class_name: "Noticed::Event", dependent: :destroy
  has_many :notifications, through: :noticed_events, class_name: "Noticed::Notification", dependent: :destroy

  has_many :entry_reads, dependent: :destroy

  private

  def post?
    entryable_type == POST_TYPE
  end

  def active?
    !trash
  end

  def entryable_content
    entryable&.content
  end

  def participants
    User.where(id: descendants.select(:user_id)).or(User.where(id: user_id)).distinct
  end

  def set_root_from_parent
    self.root_id = parent.root_id
  end

  def set_self_as_root
    update_column(:root_id, id)
  end

  def root_consistency
    errors.add(:root_id, "cannot be changed once set root_id")
  end
end
