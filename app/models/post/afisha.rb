# frozen_string_literal: true

module Post::Afisha
  extend ActiveSupport::Concern

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

  included do
    enum :afisha_status, {
      upcoming: "upcoming",
      today: "today",
      ongoing: "ongoing",
      finished: "finished"
    }, default: :upcoming

    # Скоуп для ленты: теперь работает очень быстро благодаря индексу на afisha_status
    scope :afisha_active, -> {
      where(is_afisha: true)
        .where("event_date <= ?", 7.days.from_now)
        .where("finished_at >= ?", 1.hour.ago)
        .order(Arel.sql("
          CASE afisha_status
            WHEN 'ongoing'  THEN 1
            WHEN 'today'    THEN 2
            WHEN 'upcoming' THEN 3
            WHEN 'finished' THEN 4
            ELSE 5
          END ASC"
        ))
        .order(event_date: :asc)
    }

    # Валидации
    validates :event_date, presence: { message: "нужно указать для Афиши" }, if: :is_afisha?
    validates :event_duration, inclusion: { in: DURATION_VARIANTS.keys }, if: :is_afisha?
    validate :event_date_cannot_be_in_the_past, if: -> { is_afisha? && event_date.present? && event_date_changed? }

    # Коллбеки: фиксируем состояние в базу ПЕРЕД сохранением
    before_validation :sync_afisha_status, if: :is_afisha?
    before_save :calculate_afisha_expiry, if: :is_afisha?

    after_commit :schedule_status_refresh, if: :is_afisha?
  end

  def end_date
    finished_at || (event_date + (event_duration || 1).hours)
  end

  def next_status_change_at
    now = Time.current
    return nil unless is_afisha?

    if upcoming?
      [ event_date, event_date.beginning_of_day ].select { |t| t > now }.min
    elsif today?
      event_date
    elsif ongoing?
      end_date
    else
      nil
    end
  end

  def schedule_status_refresh
    run_at = next_status_change_at
    return unless run_at

    CleanupExpiredAfishasJob.set(wait_until: run_at).perform_later(id)
  end

  def sync_afisha_status
    return unless is_afisha?
    self.afisha_status = calculate_afisha_status.to_s
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

  def afisha_state
    if is_afisha? && (new_record? || event_date_changed? || event_duration_changed?)
      calculate_afisha_status.to_sym
    else
      (afisha_status || calculate_afisha_status).to_sym
    end
  end

  def duration_text
    return "" if event_duration.blank?
    event_duration >= 24 ? "#{event_duration / 24} дн." : "#{event_duration} ч."
  end

  private

  def calculate_afisha_expiry
    return unless event_date.present? && event_duration.present?
    self.finished_at = event_date.to_datetime + event_duration.hours
  end

  def event_date_cannot_be_in_the_past
    # Если запись уже в базе и дата по факту не изменилась (с точностью до минуты) — выходим
    if persisted? && event_date_was.present?
      return if event_date.to_i / 60 == event_date_was.to_i / 60
    end

    # Если дату реально меняют на новую:
    # Проверяем на прошлое с запасом в 15 минут
    if event_date.present? && event_date < 15.minutes.ago
      errors.add(:event_date, "не может быть в прошлом")
    end
  end
end
