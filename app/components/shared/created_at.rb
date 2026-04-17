# frozen_string_literal: true

class Components::Shared::CreatedAt < Phlex::HTML
  include Phlex::Rails::Helpers::TimeTag
  include Phlex::Rails::Helpers::DOMID

  def initialize(
    entry:
  )
    @entry = entry
  end

  def view_template
    local_time = @entry.created_at.in_time_zone(Time.zone)
    local_date = local_time.to_date
    now = Time.current.in_time_zone(Time.zone)
    today = now.to_date

    if local_time.year != today.year
      time_tag(@entry.created_at, format: "%d %B %Y")

    # Если прошло меньше 2 часов — показываем "X минут назад"
    elsif now < local_time + 2.hours
      span(id: dom_id(@entry, :created_at)) { render Components::Shared::TimeInWords.new(entry: @entry) }

    # Если прошло больше 2 часов, но всё еще сегодня
    elsif local_date == today
      time_tag(@entry.created_at, format: "сегодня в %H:%M")

    elsif local_date == today - 1.day
      time_tag(@entry.created_at, format: "вчера в %H:%M")

    elsif local_date == today - 2.days
      time_tag(@entry.created_at, format: "позавчера в %H:%M")

    else
      time_tag(@entry.created_at, format: "%e %B в %H:%M")
    end
  end
end
