# frozen_string_literal: true

class Views::Entries::Show < Views::Base
  def initialize(entry:)
    @entry = entry
  end

  def view_template
    turbo_stream_from "entries"

    span(class: "mr-2") { @entry.user.username(:full) }
    span(class: "text-xs") { render Components::Shared::CreatedAt.new(entry: @entry) }
    div(class: "lexxy-show") { @entry.content.to_s }

    if @entry.entryable.no_comments?
      plain "Без комментариев"
    end
  end
end
