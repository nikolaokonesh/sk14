# frozen_string_literal: true

class Components::Shared::CreatedAt < Phlex::HTML
  include Phlex::Rails::Helpers::TimeTag
  include Phlex::Rails::Helpers::TurboStreamFrom

  def initialize(
    entry:
  )
    @entry = entry
  end

  def view_template
    local_date = @entry.created_at.in_time_zone(Time.zone)
    now = Time.current

    if local_date.year != now.year
      time_tag(@entry.created_at, format: "%d %B %Y")
    elsif now < local_date + 1.day
      span(id: "created_at_#{@entry.id}") do
        render Components::Shared::RelativeTimeInWords.new(entry: @entry)
      end
    else
      time_tag(@entry.created_at, format: "%d %B в %H:%M")
    end
  end
end
