class Entry < ApplicationRecord
  # broadcasts_refreshes

  delegated_type :entryable, types: %w[ Post Comment ], dependent: :destroy
  delegate :title, :content, to: :entryable, allow_nil: true
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

  # Твой запрос: прямая связь для получения комментариев
  # Мы ищем среди детей (replies) только те, где entryable_type это Comment
  has_many :comments, -> { where(entryable_type: "Comment") },
           class_name: "Entry", foreign_key: :root_id

  has_many :entry_keywords, dependent: :destroy
  has_many :tags, through: :entry_keywords
  after_commit :enqueue_keyword_extraction, on: [ :create, :update ]

  # Это БОНУС для списка вложенных Постов
  # has_many :sub_posts, -> { where(entryable_type: "Post") },
  #          class_name: "Entry",
  #          foreign_key: :parent_id

  has_many :reactions, dependent: :destroy
  has_many :noticed_events, as: :record, dependent: :destroy, class_name: "Noticed::Event"
  has_many :notifications, through: :noticed_events, dependent: :destroy, class_name: "Noticed::Notification"
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

  # считывание участников ветки
  def participants
    User.where(id: descendants.select(:user_id)).or(User.where(id: user_id)).distinct
    # user_ids = [ user_id ] + comments.pluck("entries.user_id")
    # User.where(id: user_ids.uniq)
  end

  # Теперь все комментарии к посту (любой вложенности) достаются так:
  def all_comments
    descendants.where(entryable_type: "Comment")
  end

  # Магия самокоренения:
  # Сначала пытаемся проставить root_id от родителя
  before_validation :set_root_from_parent, if: :parent_id?
  # Если это корень, проставляем root_id = id после создания
  after_create :set_self_as_root, unless: :root_id?

  validate :root_consistency, on: :update, if: :root_id_changed?

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

    scope = if entryable_type == "Comment"
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

  def enqueue_keyword_extraction
    return unless post? && active?
    ExtractEntryKeywordsJob.perform_later(self.id)
  end

  def post?
    entryable_type == "Post"
  end

  def active?
    !trash
  end

  def set_root_from_parent
    # Если мы отвечаем на что то, наш корень - это корень родителя
    self.root_id = parent.root_id
  end

  def set_self_as_root
    # Если это исходный Пост, у него нет parent_id и root_id
    # Делаем его корнем самого себя.
    update_column(:root_id, id)
  end

  def root_consistency
    errors.add(:root_id, "cannot be changed once set root_id")
  end
end
