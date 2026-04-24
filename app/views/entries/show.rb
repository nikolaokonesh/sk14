# frozen_string_literal: true

class Views::Entries::Show < Views::Base
  def initialize(entry:)
    @entry = entry
  end

  def view_template
    turbo_stream_from(@entry)

    div(class: "py-4") do
      # Блок автора (мета)
      div(class: "flex items-center text-lg px-2") do
        span(class: "mr-2 font-bold") { @entry.user.username(:full) }
        span(class: "text-xs opacity-60") { render Components::Shared::CreatedAt.new(entry: @entry) }
        if show_read_state_badge?
          turbo_frame_tag "read", src: entry_path(@entry), class: "opacity-0 w-0", loading: :lazy
        end

        if authenticated? && can?(:manage, @entry)
          div(class: "dropdown dropdown-end") do
            div(tabindex: 0, role: "button", class: "px-2 cursor-pointer") { lucide_icon("ellipsis") }
            ul(tabindex: -1, class: "dropdown-content menu bg-base-300 rounded-box z-100 p-2 shadow-sm") do
              div(class: "flex gap-2") do
                a(href: edit_entry_path(@entry), class: "btn btn-success") { lucide_icon("pencil") } if can?(:update, @entry)
                if @entry.trash == true
                  if can?(:restore, @entry)
                    a(href: trash_path(@entry, format: :html),
                      data: { turbo_method: :put, turbo_confirm: "Вы точно хотите восстановить?" },
                      class: "btn btn-warning") { lucide_icon("rotate-ccw") }
                  end
                else
                  a(href: entry_path(@entry, format: :html),
                    data: { turbo_method: :delete, turbo_confirm: (current_user&.has_role?(:admin) && @entry.user_id != current_user.id ? "Удалить навсегда?" : "Вы точно хотите удалить?") },
                    class: "btn btn-error") { lucide_icon("trash") }
                end
              end
            end
          end
        end
      end
      div(class: "p-2") do
        render Components::Entries::TagsListing.new(entry: @entry)
      end

      # КОНТЕЙНЕР С РАДУЖНЫМ СВЕЧЕНИЕМ
      div(class: "relative") do
        # Радужная подложка (glow)
        render Components::Shared::BgGradient.new

        # Основная карточка
        div(class: "relative bg-base-200/70 rounded-2xl shadow-xl overflow-hidden") do
          div(class: "p-4") do
            div(class: "lexxy-show text-lg leading-relaxed prose prose-stone max-w-none") { @entry.content.to_s }
            plain @entry.entryable.duration.to_s

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
