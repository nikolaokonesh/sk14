class Post < ApplicationRecord
  broadcasts_refreshes
  has_one :entry, as: :entryable, touch: true, dependent: :destroy

  # Теперь здесь только системные настройки
  has_delegated_json :setting,
                     no_comments: false,
                     duration: "forever"

  scope :afisha_active, -> {
    today = Time.current.to_date
    limit_time = 6.hours.ago.utc

    where(is_afisha: true)
      .where("event_date <= ?", today + 7.days)
      .where("manual_finished = ? OR finished_at >= ?", false, limit_time)
      .where("date(event_date, '+' || event_duration || ' days') >= ?", today.to_s)
  }

  # Теги остаются в JSON (это удобно)
  has_delegated_json :tags_listing,
                     urgent: false, important: false, event: false,
                     question: false, sell: false, buy: false, help: false

  TAG_CONFIG = {
    urgent:    { label: "Срочно!",  color_bg: "bg-rose-500/20", color_text: "text-rose-500" },
    important: { label: "Важное",   color_bg: "bg-yellow-500/20", color_text: "text-yellow-500" },
    event:     { label: "Событие",  color_bg: "bg-blue-500/20", color_text: "text-blue-500" },
    question:  { label: "Вопрос",   color_bg: "bg-teal-500/20", color_text: "text-teal-500" },
    sell:      { label: "Продам",   color_bg: "bg-green-500/20", color_text: "text-green-500" },
    buy:       { label: "Куплю",    color_bg: "bg-orange-500/20", color_text: "text-orange-500" },
    help:      { label: "Помощь",   color_bg: "bg-purple-500/20", color_text: "text-purple-500" }
  }.freeze

  validates :event_date, presence: { message: "нужно указать для Афиши" }, if: :is_afisha?
  validate :event_date_cannot_be_in_the_past, if: -> { is_afisha? && event_date.present? && event_date_changed? }

  before_validation :sanitize_settings_logic

  private

  def event_date_cannot_be_in_the_past
    # Используем .to_datetime для надежности сравнения
    if event_date.to_datetime < Time.current
      errors.add(:event_date, "не может быть в прошлом")
    end
  end

  def sanitize_settings_logic
    if is_afisha?
      # Если Афиша — чистим теги категорий и ставим срок forever
      self.duration = "forever"
      TAG_CONFIG.each_key { |key| self.send("#{key}=", false) }
    else
      # Если не Афиша — обнуляем все колонки афиши
      self.event_date = nil
      self.event_duration = 1
      self.manual_finished = false
      self.finished_at = nil
    end
  end
end
