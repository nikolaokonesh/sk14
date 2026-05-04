class Entry < ApplicationRecord
  broadcasts_refreshes
  include Threading
  include Content
  POST_TYPE = "Post".freeze
  ADVERTISEMENT_TYPE = "Advertisement".freeze
  TITLE_PREVIEW_LENGTH = 500

  delegated_type :entryable, types: [ POST_TYPE, ADVERTISEMENT_TYPE ], dependent: :destroy
  accepts_nested_attributes_for :entryable
  delegate :urgent, :important, :event, :question, :sell, :buy, :help, to: :entryable, allow_nil: true
  delegate :is_afisha?, :afisha_state, :event_date, to: :entryable, allow_nil: true

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

  def participants
    User.where(id: descendants.select(:user_id)).or(User.where(id: user_id)).distinct
  end

  # Оптимизируем получение заголовка (чтобы не дергать ActionText лишний раз в ленте)
  def title
    # self[:title] обращается напрямую к колонке в базе данных
    # Если колонка пустая (для старых постов), можно оставить фоллбэк на контент
    self[:title].presence || content&.to_plain_text&.truncate(200) || "Без заголовка"
  end

  def images_count
    # Используем значение из колонки
    self[:images_count] || 0
  end

  private

  def active?
    !trash
  end
end
