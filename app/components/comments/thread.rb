# frozen_string_literal: true

class Components::Comments::Thread < Components::Base
  def initialize(entry:)
    @entry = entry
  end

  def view_template
    turbo_stream_from(@entry, :comments)

    section(class: "mt-8") do
      div(class: "mb-3 flex items-center justify-between") do
        h3(class: "text-lg font-bold") { "Обсуждение" }
        span(class: "text-xs opacity-60") { "Режим чата" }
      end

      turbo_frame_tag dom_id(@entry, :comments_container),
                      src: entry_comments_path(@entry),
                      loading: :lazy do
        div(class: "flex justify-center rounded-2xl bg-base-200/40 p-4") { span(class: "loading loading-dots text-primary") }
      end

      if authenticated? && !@entry.entryable.no_comments?
        render Components::Comments::Form.new(entry: @entry)
      elsif @entry.entryable.no_comments?
        p(class: "text-sm italic opacity-60 mt-3") { "Комментарии отключены" }
      end
    end
  end
end
