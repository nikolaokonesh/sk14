# frozen_string_literal: true

class Views::Entries::Show < Views::Base
  def initialize(entry:, params_comment_id: nil)
    @entry = entry
    @params_comment_id = params_comment_id
  end

  def page_title = truncate(@entry.title, length: 50, omission: "...")
  def layout = Layout

  def view_template
    turbo_frame_tag :entries_list, refresh: :morph do
      turbo_stream_from :entries
      div(class: "flex flex-col h-[100dvh] w-full overflow-hidden") do
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
        div(class: "flex-1 overflow-y-auto overscroll-contain snap-y snap-proximity scroll-smooth") do
          div(class: "chat chat-start items-end pb-4 m-1") do
            div(class: "chat-image avatar sticky bottom-2 self-end") do
              div(class: "w-10 rounded-full") do
                a(href: user_path(@entry.user), target: "_top") do
                  render Components::Users::Avatar.new(user: @entry.user)
                end
              end
            end
            div(class: "chat-header flex items-center snap-start snap-always") do
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
                      a(href: edit_entry_path(@entry), data: { turbo_frame: "entry_modal" }) { "Редактировать" }
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
          turbo_frame_tag :comments, src: entry_comments_path(@entry.root, comment_id: @params_comment_id), refresh: "morph", target: "_top",
            class: "flex flex-col" do
            render Components::Pagination::Skeleton.new
          end
        end
      end
    end
  end
end
