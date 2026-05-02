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
    scope :afisha_active, -> {
      limit_time = 1.hour.ago

      where(is_afisha: true)
        .where("event_date <= ?", Time.current + 7.days)
        .where("finished_at >= ?", limit_time)
        .order(event_date: :asc)
    }

    validates :event_date, presence: { message: "нужно указать для Афиши" }, if: :is_afisha?
    validates :event_duration, inclusion: { in: DURATION_VARIANTS.keys }, if: :is_afisha?
    validate :event_date_cannot_be_in_the_past, if: -> { is_afisha? && event_date.present? && event_date_changed? }

    before_validation :sync_afisha_status
    before_save :calculate_afisha_expiry, if: :is_afisha?
  end

  def afisha_state
    calculate_afisha_status
  end

  def duration_text
    return "" if event_duration.blank?

    event_duration >= 24 ? "#{event_duration / 24} дн." : "#{event_duration} ч."
  end

  def end_date
    finished_at || (event_date + event_duration.hours)
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

  private

  def calculate_afisha_expiry
    return unless event_date.present? && event_duration.present?

    self.finished_at = event_date.to_datetime + event_duration.hours
  end

  def event_date_cannot_be_in_the_past
    errors.add(:event_date, "не может быть в прошлом") if event_date.to_datetime < Time.current
  end

  def sync_afisha_status
    return unless is_afisha?

    self.afisha_status = calculate_afisha_status.to_s
  end
end
