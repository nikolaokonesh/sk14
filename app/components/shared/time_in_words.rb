# frozen_string_literal: true

class Components::Shared::TimeInWords < Phlex::HTML
  register_value_helper :time_ago_in_words

  def initialize(
    entry:
  )
    @entry = entry
  end

  def view_template
    plain time_ago_in_words(@entry.created_at)
  end
end
