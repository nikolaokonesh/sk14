class AutoService < ApplicationRecord
  STATE_OFF = "off".freeze
  STATE_MANUAL = "manual".freeze
  STATE_SCHEDULE = "schedule".freeze

  DAY_OPTIONS = [
    [ "Понедельник", "mon" ],
    [ "Вторник", "tue" ],
    [ "Среда", "wed" ],
    [ "Четверг", "thu" ],
    [ "Пятница", "fri" ],
    [ "Суббота", "sat" ],
    [ "Воскресенье", "sun" ]
  ].freeze

  SERVICE_KINDS = [
    [ "Такси", "taxi" ],
    [ "Кран", "crane" ],
    [ "Погрузчик", "loader" ],
    [ "Грузовик", "truck" ],
    [ "Другое", "other" ]
  ].freeze

  SCHEDULE_MODES = [ [ "Всегда доступен", "always" ], [ "Гибкий график", "flexible" ] ].freeze

  has_one :entry, as: :entryable, touch: true, dependent: :destroy

  attribute :activity_state, :string, default: STATE_OFF

  validates :service_kinds, presence: true
  validates :car_brand, :plate_number, :phone, presence: true
  validates :schedule_mode, inclusion: { in: SCHEDULE_MODES.map(&:last) }
  validates :activity_state, inclusion: { in: [ STATE_OFF, STATE_MANUAL, STATE_SCHEDULE ] }
  validates :city_trip_price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  before_validation :sync_active_with_state
  after_commit :broadcast_auto_services_refresh

  def service_kind_names
    mapping = SERVICE_KINDS.to_h.invert
    service_kinds.filter_map { |kind| mapping[kind] }
  end

  def work_days_array
    work_days.to_s.split(",").map(&:strip).reject(&:blank?)
  end

  def work_days_array=(value)
    normalized = Array(value).map(&:to_s).map(&:strip).reject(&:blank?)
    self.work_days = normalized.join(",")
  end

  def schedule_label
    return "Всегда" if schedule_mode == "always"

    days = work_day_labels.join(", ")
    time = [ work_from.presence, work_to.presence ].compact.join("-")
    schedule = [ days.presence, time.presence ].compact.join(" ")
    schedule.presence || "Гибкий"
  end

  def available_now?(now = Time.current)
    return false if off?
    return true if manual?

    available_day?(now) && available_time?(now)
  end

  def fresh_for_passenger?
    return false unless available_now?

    reference_time = activated_at || updated_at || created_at
    reference_time.present? && reference_time >= 10.minutes.ago
  end

  def set_activity!(state)
    case state
    when STATE_OFF
      update!(activity_state: STATE_OFF, available_snapshot: false)
    when STATE_MANUAL
      update!(activity_state: STATE_MANUAL, activated_at: Time.current, available_snapshot: true)
    when STATE_SCHEDULE
      initial_available = available_day?(Time.current) && available_time?(Time.current)
      update!(
        activity_state: STATE_SCHEDULE,
        activated_at: (initial_available ? Time.current : activated_at),
        available_snapshot: initial_available
      )
    else
      errors.add(:activity_state, "не поддерживается")
      raise ActiveRecord::RecordInvalid, self
    end
  end

  def off? = activity_state == STATE_OFF
  def manual? = activity_state == STATE_MANUAL
  def schedule? = activity_state == STATE_SCHEDULE

  private

  def work_day_labels
    mapping = DAY_OPTIONS.to_h
    work_days_array.filter_map { |code| mapping.invert[code] }
  end

  def sync_active_with_state
    self.active = !off?
  end

  def available_day?(now)
    return true if work_days_array.empty?

    work_days_array.include?(day_code_for_wday(now.wday))
  end

  def day_code_for_wday(wday)
    %w[sun mon tue wed thu fri sat][wday]
  end

  def available_time?(now)
    return true if work_from.blank? || work_to.blank?

    from_minutes = parse_time_minutes(work_from)
    to_minutes = parse_time_minutes(work_to)
    return true unless from_minutes && to_minutes

    current_minutes = now.hour * 60 + now.min

    if from_minutes <= to_minutes
      current_minutes.between?(from_minutes, to_minutes)
    else
      current_minutes >= from_minutes || current_minutes <= to_minutes
    end
  end

  def parse_time_minutes(value)
    parts = value.to_s.split(":")
    return nil unless parts.size == 2

    hours = parts[0].to_i
    mins = parts[1].to_i
    return nil if hours.negative? || hours > 23 || mins.negative? || mins > 59

    hours * 60 + mins
  end

  def broadcast_auto_services_refresh
    Turbo::StreamsChannel.broadcast_refresh_to(:auto_services)
  end
end
