class Post < ApplicationRecord
  broadcasts_refreshes
  has_one :entry, as: :entryable, touch: true, dependent: :destroy

  has_delegated_json :setting,
                     no_comments: false,
                     duration: "forever",
                     is_afisha: false,     # Режим афиши
                     event_date: "" ,      # Дата события
                     event_duration: 1 

  scope :afisha_active, -> {
    today = Time.current.to_date
    
    # Извлекаем все поля из JSON-столбца 'setting'
    where("json_extract(setting, '$.is_afisha') = ?", true)
      .where("date(json_extract(setting, '$.event_date')) <= ?", today + 7.days)
      .where("date(json_extract(setting, '$.event_date'), '+' || CAST(json_extract(setting, '$.event_duration') AS INT) || ' days') >= ?", today.to_s)
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
    urgent:    { label: "Срочно!",  color_bg: "bg-rose-500/20", color_text: "text-rose-500" },
    important: { label: "Важное",   color_bg: "bg-yellow-500/20", color_text: "text-yellow-500" },
    event:     { label: "Событие",  color_bg: "bg-blue-500/20", color_text: "text-blue-500" },
    question:  { label: "Вопрос",   color_bg: "bg-teal-500/20", color_text: "text-teal-500" },
    sell:      { label: "Продам",   color_bg: "bg-green-500/20", color_text: "text-green-500" },
    buy:       { label: "Куплю",    color_bg: "bg-orange-500/20", color_text: "text-orange-500" },
    help:      { label: "Помощь",   color_bg: "bg-purple-500/20", color_text: "text-purple-500" }
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
      self.duration = "forever"
      TAG_CONFIG.each_key { |key| self.send("#{key}=", false) }
    else
      self.event_date = ""
      self.event_duration = 1
    end
  end
end
