# frozen_string_literal: true

class Views::Entries::Show < Views::Base
  def initialize(entry:)
    @entry = entry
  end

  def view_template
    turbo_stream_from(@entry)

    div(class: "flex items-center") do
      span(class: "mr-2") { @entry.user.username(:full) }
      span(class: "text-xs") { render Components::Shared::CreatedAt.new(entry: @entry) }
      if show_read_state_badge?
        turbo_frame_tag "read", src: entry_path(@entry),
                                class: "opacity-0 w-0",
                                loading: :lazy
      end
    end

    div(class: "lexxy-show") { @entry.content.to_s }

    if @entry.entryable.no_comments?
      plain "Без комментариев"
    end
  end

  private

  def show_read_state_badge?
    return false unless current_user
    return false if @entry.user == current_user
    return false if Current.user.post_read_for?(@entry)
    return false unless @entry.entryable_type == "Post"
    true
  end
end
