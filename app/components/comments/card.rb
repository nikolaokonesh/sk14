# frozen_string_literal: true

class Components::Comments::Card < Phlex::HTML
  include Phlex::Rails::Helpers::Routes
  include Phlex::Rails::Helpers::Truncate
  include Phlex::Rails::Helpers::Sanitize
  include Phlex::Rails::Helpers::StripTags
  include Phlex::Rails::Helpers::DOMID
  register_value_helper :lucide_icon
  register_value_helper :current_user_id

  def initialize(entry:, highlight: false, is_last_in_group: true, class_target: nil)
    @entry = entry
    @comment = entry.entryable
    @highlight = highlight
    @is_last_in_group = is_last_in_group
    @class_target = class_target
  end

  def view_template
    yield
  end

  def nav
    span(class: "hidden dropdown dropdown-left dropdown-center",
        data: { auth_visibility_target: "controls" }) do
      div(tabindex: 0, role: "button", class: "px-1.5 cursor-pointer") { lucide_icon("ellipsis") }
      ul(tabindex: -1, id: "dropdown_comment_hide_#{@comment.id}", class: "dropdown-content menu bg-base-300 rounded-box z-1 w-52 p-2 z-50 shadow-sm") do
        li do
          a(href: edit_entry_comment_path(@entry, @comment), data: { turbo_stream: true, turbo_prefetch: "false" }) { "Редактировать" }
        end
        li do
          a(href: entry_comment_path(@entry, @comment), data: { turbo_method: :delete, turbo_confirm: "Вы точно хотите удалить?" }) { "Удалить" }
        end
      end
    end
  end

  def content
    # plain "#{@entry.root.entryable.id}" Это ID Поста
    div(id: "content_comment_#{@comment.id}", class: "p-2") do
      render Components::Entries::Content.new(entry: @comment)
    end
  end

  def card_comment
    div(id: dom_id(@entry),
        data: { controller: "auth-visibility chat-visibility #{(@highlight ? "highlight" : nil)}",
                auth_visibility_author_id_value: @entry.user_id,
                chat_visibility_target: "chat" },
        class: "chat chat-start comment-card items-end m-1 #{@class_target}") do
      div(class: "chat-image avatar sticky bottom-2 self-end", data: { chat_visibility_target: "avatar" }) do
        div(class: "w-10 rounded-full") do
          if @is_last_in_group
            render Components::Users::Avatar.new(user: @entry.user)
          end
        end
      end
      div(class: "chat-header flex items-center") do
        span(class: "pr-3", data: { chat_visibility_target: "username" }) { sanitize(strip_tags(@entry.user.username)) }
        time(class: "opacity-50") { render Components::Shared::TimeAgoInWords.new(entry: @comment) }
        nav
      end
      div(data: { chat_visibility_target: "bgcolor" }, class: [ "chat-bubble p-0 max-w-[99%]", ("before:hidden" unless @is_last_in_group), (@highlight ? "animate-shimmer-bottom" : nil) ]) do
        if @comment.entry.parent.entryable_type == "Comment"
          a(
            href: entry_comments_path(@comment.entry.root, comment_id: @comment.entry.parent.id),
            data: { turbo_frame: "comments", action: "click->autoscroll#disable_click" }
          ) do
            div(class: "flex flex-col overflow-hidden bg-base-200 border-l-4 border-primary px-4 py-2") do
              span(class: "text-primary text-sm font-bold truncate") { @comment.entry.parent.user.username }
              span(class: "text-base-content/70 text-xs truncate") { truncate(@comment.entry.parent.entryable.content.to_plain_text.to_s, length: 50, omission: "...") }
            end
          end
        end
        content
      end
      div(class: "chat-footer opacity-50",
          data: {
            action: "click->reply#trigger",
            reply_id_param: @comment.entry.id,
            reply_author_param: @entry.user.username,
            reply_text_param: truncate(@comment.content.to_plain_text.to_s,
            length: 50,
            omission: "...")
          }
      ) do
        span(class: "cursor-pointer") { "Ответить" }
      end
    end
  end

  def card_comment_for_root_page
    div(id: dom_id(@entry)) do
      div(class: "flex flex-col overflow-hidden bg-base-200 border-l-4 border-primary px-4 py-2 rounded-r-lg shadow-sm") do
        if @comment.entry.parent.entryable_type == "Comment"
          span(class: "text-xs font-bold") { "Ответил пользователю:" }
          span(class: "text-primary text-sm") { "#{@comment.entry.parent.user.username}" }
          span(class: "text-base-content/70 text-xs truncate") { truncate(@comment.entry.parent.entryable.content.to_plain_text.to_s, length: 50, omission: "...") }
          span(class: "text-xs font-bold") { "Пост:" }
        else
          div(class: "text-xs font-bold") { "Комментарий к посту:" }
        end
        span(class: "text-base-content/70 text-xs truncate") { truncate(@entry.root.entryable.title, length: 100, omission: "...") }
      end
      div(class: "p-2") do
        content
        a(href: entry_comments_path(@comment.entry.root, comment_id: @comment.entry.id), data: { turbo_frame: "_top" }) do
          span(aria_hidden: "true", class: "absolute inset-0") { }
        end
      end
    end
  end
end
