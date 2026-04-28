# frozen_string_literal: true

class Components::Shared::CreatedAt < Phlex::HTML
  include Phlex::Rails::Helpers::TimeTag
  include Phlex::Rails::Helpers::DOMID
  register_value_helper :lucide_icon

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

    if !local_time.this_year?
      span(class: "flex items-top gap-1") do
        plain raw lucide_icon("clock", size: 12, class: "opacity-25")
        time_tag(@entry.created_at, format: "%d %B %Y")
      end

    # Если прошло меньше 2 часов — показываем "X минут назад"
    elsif now < local_time + 3.hours
      span(class: "flex items-top gap-1") do
        plain raw lucide_icon("clock", size: 12, class: "text-error")
        span(id: dom_id(@entry, :created_at)) { render Components::Shared::TimeInWords.new(entry: @entry) }
      end

    # Если прошло больше 2 часов, но всё еще сегодня
    elsif local_date.today?
      span(class: "flex items-top gap-1") do
        plain raw lucide_icon("clock", size: 12, class: "text-warning")
        time_tag(@entry.created_at, format: "сегодня в %H:%M")
      end

    elsif local_date.yesterday?
      span(class: "flex items-top gap-1") do
        plain raw lucide_icon("clock", size: 12, class: "text-success")
        time_tag(@entry.created_at, format: "вчера в %H:%M")
      end

    elsif local_date == today - 2.days
      span(class: "flex items-top gap-1") do
        plain raw lucide_icon("clock", size: 12, class: "text-info")
        time_tag(@entry.created_at, format: "позавчера в %H:%M")
      end
    else
      span(class: "flex items-top gap-1") do
        plain raw lucide_icon("clock", size: 12, class: "opacity-60")
        time_tag(@entry.created_at, format: "%e %B в %H:%M")
      end
    end
  end
end
