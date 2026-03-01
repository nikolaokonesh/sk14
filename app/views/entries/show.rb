# frozen_string_literal: true

class Views::Entries::Show < Views::Base
  def initialize(
    entry:,
    comments:,
    pagy: nil,
    direction: nil,
    highlight_id: nil,
    frame_id: nil,
    has_prev: false,
    has_next: false,
    button_down: false
  )
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
    div(id: dom_id(@entry, :show_container), data: { controller: "reply" }, class: "snap-y snap-proximity scroll-smooth w-full") do
      if @entry.trash == true
        div(class: "flex items-center mt-5 snap-start") do
          div(class: "bg-red-500 inline p-1 m-2") { "Удалено" }
          div(class: "flex items-center") do
            span { "Вы можете восстановить пост" }
            a(href: trash_path(@entry, format: :html), class: "mx-auto p-2 active:text-red-500", data: { turbo_method: :put, turbo_confirm: "Вы точно хотите восстановить?" }) { lucide_icon("rotate-ccw") }
          end
        end
        span(class: "ml-2 text-sm text-slate-500") { "Внимание! Cкоро будет удален навсегда." }
      end

      # snap-y snap-proximity scroll-smooth Это для залипания
      div(class: "chat chat-start snap-end items-end pb-4 m-1") do
        div(class: "chat-image avatar sticky bottom-2 self-end") do
          div(class: "w-10 rounded-full") do
            a(href: user_path(@entry.user)) do
              render Components::Users::Avatar.new(user: @entry.user)
            end
          end
        end
        div(class: "chat-header flex items-center") do
          span(class: "pr-1.5 text-base") do
            a(href: user_path(@entry.user), class: "hover:opacity-80 duration-200") do
              sanitize(strip_tags(@entry.user.name_full))
            end
          end
          time(class: "opacity-50") { render Components::Shared::TimeAgoInWords.new(entry: @entry) }
          if authenticated? && can?(:manage, @entry)
            div(class: "dropdown dropdown-end",
                data: { auth_visibility_target: "controls" }) do
              div(tabindex: 0, role: "button", class: "px-2 cursor-pointer") { lucide_icon("ellipsis") }
              ul(tabindex: -1, class: "dropdown-content menu bg-base-300 rounded-box z-100 w-52 p-2 shadow-sm") do
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
        render Components::Reactions::Interactive.new(
          entry: @entry,
          id: "content_#{dom_id(@entry)}",
          class_name: "chat-bubble max-w-full relative",
          with_controller: true
        ) do
          render Components::Entries::Content.new(entry: @entry)
        end
        div(class: "chat-footer opacity-50") { render Components::Entries::Tags.new(entry: @entry) }
      end

      div(class: "relative h-15 -mb-15 bg-gradient-to-b from-base-200 to-transparent z-10 pointer-events-none") { }

      # Лента комментариев
      render Views::Comments::Index.new(entry: @entry,
                                        comments: @comments,
                                        pagy: @pagy,
                                        direction: @direction,
                                        highlight_id: @highlight_id,
                                        frame_id: @frame_id,
                                        has_prev: @has_prev,
                                        has_next: @has_next,
                                        button_down: @button_down)

      # Форма ввода комментария (прижата к низу)
      if current_user
        # reply_controller внутри Form::Create.rb
        div(id: "new_comment_form", class: "flex-none bg-base-200 p-4 pb-safe z-10") do
          render Components::Comments::Form::Create.new(entry: @entry, has_next: @has_next, pagy: @pagy)
        end
      end
      # snap-end snap-always Это для залипания
      div(class: "snap-end") { }
    end
  end
end
