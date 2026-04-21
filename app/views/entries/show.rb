# frozen_string_literal: true

class Views::Entries::Show < Views::Base
  def initialize(entry:)
    @entry = entry
  end

  def view_template
    turbo_stream_from(@entry)

    div(class: "max-w-4xl mx-auto py-4") do
      # Блок автора (мета)
      div(class: "flex items-center text-lg mb-4 px-2") do
        span(class: "mr-2 font-bold") { @entry.user.username(:full) }
        span(class: "text-xs opacity-60") { render Components::Shared::CreatedAt.new(entry: @entry) }
        if show_read_state_badge?
          turbo_frame_tag "read", src: entry_path(@entry), class: "hidden", loading: :lazy
        end
      end

      # КОНТЕЙНЕР С РАДУЖНЫМ СВЕЧЕНИЕМ
      div(class: "relative") do
        # Радужная подложка (glow)
        render Components::Shared::BgGradient.new

        # Основная карточка
        div(class: "relative bg-base-200/90 dark:bg-base-200/70 rounded-2xl shadow-xl overflow-hidden") do
          div(class: "p-4") do
            div(class: "lexxy-show text-lg leading-relaxed prose prose-stone max-w-none") { @entry.content.to_s }

            if @entry.entryable.no_comments?
              div(class: "divider opacity-10 mt-2")
              p(class: "text-sm italic opacity-50 text-center") { "Без комментариев" }
            end
          end
        end
      end
    end
  end

  private

  def show_read_state_badge?
    return false unless current_user
    return false if @entry.user == current_user
    return false if Current.user.post_read_for?(@entry)
    return false unless @entry.post?
    true
  end
end
