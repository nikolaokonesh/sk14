class Post < ApplicationRecord
  broadcasts_refreshes
  has_one :entry, as: :entryable, touch: true, dependent: :destroy

  has_delegated_json :setting,
                     no_comments: false,
                     duration: "forever",
                     is_afisha: false,     # Режим афиши
                     event_date: ""       # Дата события

  # Scope для раздела АФИША: неделя до события + сам день события
  scope :afisha_active, -> {
    where("setting->>'is_afisha' = ?", "true")
    .where("setting->>'event_date' IS NOT NULL")
    .where("(setting->>'event_date')::timestamp BETWEEN ? AND ?",
           1.week.ago.beginning_of_day,
           Time.current.end_of_day)
  }

  # Все теги как логические поля
  has_delegated_json :tags_listing,
                     urgent: false,
                     important: false,
                     event: false,
                     question: false,
                     sell: false,
                     buy: false,
                     help: false

  # Справочник для рендеринга
  TAG_CONFIG = {
    urgent:    { label: "Срочно!",  color: "bg-rose-700" },
    important: { label: "Важное",   color: "bg-yellow-700" },
    event:     { label: "Событие",  color: "bg-blue-700" },
    question:  { label: "Вопрос",   color: "bg-teal-700" },
    sell:      { label: "Продам",   color: "bg-green-700" },
    buy:       { label: "Куплю",    color: "bg-orange-700" },
    help:      { label: "Помощь",   color: "bg-purple-700" }
  }.freeze

  # Валидация: поле event_date должно быть заполнено, если это афиша
  validates :event_date, presence: { message: "нужно указать для Афиши" }, if: :is_afisha?

  # Дополнительно: проверка, что дата не в прошлом (по желанию)
  validate :event_date_cannot_be_in_the_past, if: -> { is_afisha? && event_date.present? }

  before_validation :sanitize_settings_logic

  private

  def event_date_cannot_be_in_the_past
    if event_date.to_datetime < Time.current
      errors.add(:event_date, "не может быть в прошлом")
    end
  end

  def sanitize_settings_logic
    if is_afisha?
      # Если Афиша — чистим категории и ставим срок forever
      self.duration = "forever"
      TAG_CONFIG.each_key { |key| self.send("#{key}=", false) }
    else
      # Если не Афиша — чистим дату
      self.event_date = ""
    end
  end
end
