class Post < ApplicationRecord
  broadcasts_refreshes
  has_one :entry, as: :entryable, touch: true, dependent: :destroy

  # Добавляем варианты длительности в часах
  DURATION_VARIANTS = {
    1 => "1 час",
    2 => "2 часа",
    3 => "3 часа",
    6 => "6 часов",
    12 => "12 часов",
    24 => "1 день",
    48 => "2 дня",
    72 => "3 дня"
  }.freeze

  # Теперь здесь только системные настройки
  has_delegated_json :setting,
                     no_comments: false,
                     duration: "forever"

  scope :afisha_active, -> {
    # Точка отсечения: 1 час назад
    limit_time = 1.hour.ago

    where(is_afisha: true)
      .where("event_date <= ?", Time.current + 7.days) # Показываем за неделю до начала
      .where("finished_at >= ?", limit_time)         # Показываем, если завершилось (само или кнопкой) менее часа назад
      .order(event_date: :asc)
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
  # Валидация новой длительности
  validates :event_duration, inclusion: { in: DURATION_VARIANTS.keys }, if: :is_afisha?
  validate :event_date_cannot_be_in_the_past, if: -> { is_afisha? && event_date.present? && event_date_changed? }

  before_validation :sanitize_settings_logic
  before_validation :sync_afisha_status
  # Рассчитываем finished_at перед сохранением
  before_save :calculate_afisha_expiry, if: :is_afisha?

  def afisha_state
    afisha_status&.to_sym || calculate_afisha_status
  end

  def duration_text
    return "" if event_duration.blank?
    if event_duration >= 24
      "#{event_duration / 24} дн."
    else
      "#{event_duration} ч."
    end
  end

  def end_date
    finished_at || (event_date + event_duration.hours)
  end

  private

  def calculate_afisha_expiry
    if event_date.present? && event_duration.present?
      self.finished_at = event_date.to_datetime + event_duration.hours
    end
  end

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
      # Дефолтное значение для корректного расчета
      self.event_duration ||= 1
    else
      # Если не Афиша — обнуляем все колонки афиши
      self.event_date = nil
      self.event_duration = 1
      self.manual_finished = false
      self.finished_at = nil
      self.afisha_status = nil
    end
  end

  def calculate_afisha_status(now = Time.current)
    return :upcoming unless is_afisha? && event_date.present?

    end_time = finished_at || (event_date + event_duration.hours)

    if manual_finished? || now > end_time
      :finished
    elsif now >= event_date && now <= end_time
      :ongoing
    elsif now.to_date == event_date.to_date
      :today
    else
      :upcoming
    end
  end

  def sync_afisha_status
    return unless is_afisha?

    self.afisha_status = calculate_afisha_status.to_s
  end
end
