# frozen_string_literal: true

class Components::Comments::Card < Phlex::HTML
  include Phlex::Rails::Helpers::Routes
  include Phlex::Rails::Helpers::Truncate
  include Phlex::Rails::Helpers::Sanitize
  include Phlex::Rails::Helpers::StripTags
  include Phlex::Rails::Helpers::DOMID
  register_value_helper :lucide_icon
  register_value_helper :current_user_id
  register_value_helper :authenticated?

  def initialize(
    entry:, 
    highlight: false, 
    class_target: "", 
    is_first: nil, 
    is_last: nil
  )
    @entry = entry
    @comment = entry.entryable
    @highlight = highlight
    @class_target = class_target
    @is_first = is_first.nil? ? @entry.first_in_group? : is_first
    @is_last = is_last.nil? ? @entry.last_in_group? : is_last
  end

  def view_template
    yield
  end

  def nav
    span(class: "hidden dropdown dropdown-left dropdown-end",
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
    div(id: "content_comment_#{@comment.id}", class: "group cursor-pointer p-2",
      data: { action: "click->reactions#togglePicker" }) do
      render Components::Entries::Content.new(entry: @comment)
      if authenticated?
        div(class: "picker-container absolute bottom-10 hidden max-w-[70vw] md:max-w-[92vw] flex justify-center animate-in zoom-in duration-250 z-90", data: { reactions_target: "picker" }) do
          render Components::Reactions::Picker.new(entry: @entry)
          button_reply_comment
        end
        render Components::Reactions::List.new(entry: @entry)
      end
    end
  end

  def card_comment
    div(id: dom_id(@entry),
        data: { controller: "auth-visibility chat-visibility reactions #{(@highlight ? "highlight" : nil)}",
                auth_visibility_author_id_value: @entry.user_id,
                chat_visibility_target: "chat" },
        class: "chat chat-start entry-card group items-end #{@class_target}") do
      div(class: "chat-header flex items-center") do
        span(class: "pr-3 text-base font-bold", data: { chat_visibility_target: "username" }) {
          sanitize(strip_tags(@entry.user.username)) if @is_first
        }
      end
      div(data: { chat_visibility_target: "bgcolor" }, class: [ "chat-bubble p-0 max-w-[98%] rounded-none", (@is_first ? "" : ""), (!@is_last ? "before:hidden mb-0" : ""), (@highlight ? "animate-shimmer-bottom" : nil) ]) do
        if @comment.entry.parent&.entryable_type == "Comment"
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
      div(class: "chat-footer") do
        time(class: "opacity-50") { render Components::Shared::TimeAgoInWords.new(entry: @comment) }
        nav
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

  def button_reply_comment
    if authenticated?
      span(class: "cursor-pointer absolute right-0 top-15 p-2 btn",
        data: {
          action: "click->reply#trigger",
          reply_id_param: @comment.entry.id,
          reply_author_param: @entry.user.username,
          reply_text_param: truncate(@comment.content.to_plain_text.to_s,
          length: 50,
          omission: "...") }) do
        raw lucide_icon("message-square-reply", size: 20)
        p { "Ответить" }
      end
    end
  end
end
