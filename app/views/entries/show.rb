# frozen_string_literal: true

class Views::Entries::Show < Views::Base
  def initialize(entry:)
    @entry = entry
  end

  def view_template
    turbo_stream_from(:entry, @entry.id)

    div(class: "flex items-center") do
      span(class: "mr-2") { @entry.user.username(:full) }
      span(class: "text-xs") { render Components::Shared::CreatedAt.new(entry: @entry) }
      turbo_frame_tag "read", src: entry_path(@entry),
                              class: "opacity-0 w-0",
                              loading: :lazy if current_user
    end

    div(class: "lexxy-show") { @entry.content.to_s }

    if @entry.entryable.no_comments?
      plain "Без комментариев"
    end
  end
end
