class Entry < ApplicationRecord
  POST_TYPE = "Post".freeze
  COMMENT_TYPE = "Comment".freeze
  TITLE_PREVIEW_LENGTH = 500

  delegated_type :entryable, types: [ POST_TYPE, COMMENT_TYPE ], dependent: :destroy
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
  after_commit :enqueue_keyword_extraction, on: [ :create, :update ]

  has_many :reactions, dependent: :destroy
  has_many :noticed_events, as: :record, class_name: "Noticed::Event", dependent: :destroy
  has_many :notifications, through: :noticed_events, class_name: "Noticed::Notification", dependent: :destroy
  has_many :entry_read_states, dependent: :destroy

  def reaction_summary
    reactions.group(:content).count
  end

  def reacted_with?(user, emoji)
    return false unless user

    reactions.exists?(user: user, content: emoji)
  end

  def current_reaction_for(user)
    reactions.find_by(user: user)
  end

  def participants
    User.where(id: descendants.select(:user_id)).or(User.where(id: user_id)).distinct
  end

  def all_comments
    descendants.where(entryable_type: COMMENT_TYPE)
  end

  before_validation :set_root_from_parent, if: :parent_id?
  after_create :set_self_as_root, unless: :root_id?

  after_save :update_truncated_content, if: :should_update_truncated_content?

  validate :root_consistency, on: :update, if: :root_id_changed?
  validates :title, length: { maximum: 200 }, allow_blank: true

  def first_in_group?
    return true if parent_id.nil?

    prev_entry = parent.replies
                       .where("created_at < ?", created_at)
                       .order(created_at: :asc)
                       .last

    prev_entry.nil? || prev_entry.user_id != user_id
  end

  def last_in_group?
    next_entry = parent&.replies
                       &.where("created_at > ?", created_at)
                       &.order(created_at: :asc)
                       &.first

    next_entry.nil? || next_entry.user_id != user_id
  end

  def group_anchor_id
    scope = Entry.active.where(entryable_type: entryable_type)

    scope = if entryable_type == COMMENT_TYPE
      scope.where(root_id: root_id)
    else
      scope.where(parent_id: nil)
    end

    last_interruption_time = scope
                            .where.not(user_id: user_id)
                            .where("created_at < ?", created_at)
                            .order(created_at: :desc)
                            .pick(:created_at)
    query = scope.where(user_id: user_id)

    if last_interruption_time
      query = query.where("created_at > ?", last_interruption_time)
    end

    query.order(created_at: :asc).pick(:id) || id
  end

  private

  def should_update_truncated_content?
    post? && (saved_change_to_entryable_type? || saved_change_to_entryable_id? || saved_change_to_updated_at?)
  end

  def update_truncated_content
    return if entryable_content.blank?

    plain_text = normalized_plain_text_content
    truncated = truncated_title_from(plain_text)

    update_column(:title, truncated)
  end

  def enqueue_keyword_extraction
    return unless post? && active?
    ExtractEntryKeywordsJob.perform_later(self.id)
  end

  def post?
    entryable_type == POST_TYPE
  end

  def active?
    !trash
  end

  def set_root_from_parent
    self.root_id = parent.root_id
  end

  def set_self_as_root
    update_column(:root_id, id)
  end

  def entryable_content
    entryable&.content
  end

  def normalized_plain_text_content
    return entryable_content.to_plain_text if entryable_content.respond_to?(:to_plain_text)

    ActionController::Base.helpers.string_tags(entryable_content.to_s).squish
  end

  def truncated_title_from(plain_text)
    return plain_text if plain_text.length <= TITLE_PREVIEW_LENGTH

    space_index = plain_text[0..TITLE_PREVIEW_LENGTH].rindex(" ") || TITLE_PREVIEW_LENGTH
    "#{plain_text[0..space_index]}..."
  end

  def root_consistency
    errors.add(:root_id, "cannot be changed once set root_id")
  end
end
