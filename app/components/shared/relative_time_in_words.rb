# frozen_string_literal: true

class Components::Shared::RelativeTimeInWords < Phlex::HTML
  register_value_helper :relative_time_in_words

  def initialize(
    entry:
  )
    @entry = entry
  end

  def view_template
    plain relative_time_in_words(@entry.created_at)
  end
end
