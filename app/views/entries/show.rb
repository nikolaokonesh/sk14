# frozen_string_literal: true

class Views::Entries::Show < Views::Base
  def initialize(entry:, comments:, pagy: nil, direction: nil, highlight_id: nil, frame_id: nil, has_prev: false, has_next: false, button_down: false)
    @entry = entry
    @comments = comments
    @pagy = pagy
    @direction = direction
    @highlight_id = highlight_id.to_i
    @frame_id = frame_id
    @has_prev = has_prev
    @has_next = has_next
    @button_down = button_down
  end


  def page_title = truncate(@entry.title, length: 50, omission: "...")
  def layout = Layout

  def view_template
    turbo_stream_from :entries
    div(class: "snap-y snap-proximity scroll-smooth w-full") do
      if @entry.trash == true
        div(class: "flex items-center mt-5") do
          div(class: "bg-red-500 inline p-1 m-2") { "Удалено" }
          div(class: "flex items-center") do
            span { "Вы можете восстановить пост" }
            a(href: trash_path(@entry, format: :html), class: "mx-auto p-2 active:text-red-500", data: { turbo_method: :put, turbo_confirm: "Вы точно хотите восстановить?" }) { lucide_icon("rotate-ccw") }
          end
        end
        span(class: "ml-2 text-sm text-slate-500") { "Внимание! Cкоро будет удален навсегда." }
      end

      # snap-y snap-proximity scroll-smooth Это для залипания
      div(class: "snap-start") do
        div(class: "chat chat-start items-end pb-4 m-1") do
          div(class: "chat-image avatar sticky bottom-2 self-end") do
            div(class: "w-10 rounded-full") do
              a(href: user_path(@entry.user), target: "_top") do
                render Components::Users::Avatar.new(user: @entry.user)
              end
            end
          end
          div(class: "chat-header flex items-center") do
            span(class: "pr-1.5") do
              a(href: user_path(@entry.user), target: "_top") do
                sanitize(strip_tags(@entry.user.name_full))
              end
            end
            time(class: "opacity-50") { render Components::Shared::TimeAgoInWords.new(entry: @entry) }
            if authenticated? && can?(:manage, @entry)
              div(class: "dropdown dropdown-end",
                  data: { auth_visibility_target: "controls" }) do
                div(tabindex: 0, role: "button", class: "px-2 cursor-pointer") { lucide_icon("ellipsis") }
                ul(tabindex: -1, class: "dropdown-content menu bg-base-300 rounded-box z-10 w-52 p-2 shadow-sm") do
                  li do
                    a(href: edit_entry_path(@entry)) { "Редактировать" }
                  end
                  li do
                    if @entry.trash == true
                      a(href: trash_path(@entry, format: :html), data: { turbo_method: :put, turbo_confirm: "Вы точно хотите восстановить?" }) { "Восстановить" }
                    else
                      a(href: entry_path(@entry, format: :html), data: { turbo_method: :delete, turbo_confirm: "Вы точно хотите удалить?" }) { "Удалить" }
                    end
                  end
                end
              end
            end
          end
          div(id: "content_#{dom_id(@entry)}", class: "chat-bubble max-w-full") {
            render Components::Entries::Content.new(entry: @entry)
          }
          div(class: "chat-footer opacity-50") { render Components::Entries::Tags.new(entry: @entry) }
        end
        # Лента комментариев
        header(class: "p-3 sticky top-0 z-5 bg-base-200 border-b font-semibold") { "Комментарии" }
        render Views::Comments::Index.new(entry: @entry,
                                          comments: @comments,
                                          pagy: @pagy,
                                          direction: @direction,
                                          highlight_id: @highlight_id,
                                          frame_id: @frame_id,
                                          has_prev: @has_prev,
                                          has_next: @has_next,
                                          button_down: @button_down)
      end
    end
  end
end
