# frozen_string_literal: true

class Components::Shared::TimeAgoInWords < Phlex::HTML
  include Phlex::Rails::Helpers::TimeTag
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
    else
      time_tag(@entry.created_at, format: "%d %B в %H:%M")
    end
  end
end
