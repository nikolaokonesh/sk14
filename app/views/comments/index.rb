# frozen_string_literal: true

class Views::Comments::Index < Views::Base
  def initialize(entry:, comments:, pagy: nil, direction: nil, highlight_id: nil, frame_id: nil, has_prev: false, has_next: false, button_down: false)
    @entry = entry
    @comments = comments
    @pagy = pagy
    @direction = direction
    @highlight_id = highlight_id.to_i
    @frame_id = frame_id
    @pagy_has_prev = has_prev
    @pagy_has_next = has_next
    @button_down = button_down
  end

  def page_title = "Комментарии поста #{@entry.id}"
  def layout = Layout

  def view_template
    turbo_frame_tag :comments, refresh: "morph" do
      turbo_stream_from [ @entry, :comments ]

      div(data: { controller: "reply" }) do
        # Контейнер:
        # 1. Убрали action: "turbo:frame-load...", так как сделали setTimeout в JS
        # 2. relative нужен для позиционирования кнопки
        div(id: dom_id(@entry.root, :comments_list),
            class: "pt-4 max-h-[71svh] overflow-y-auto",
            data: { controller: "autoscroll infinite-scroll" }) do
          @direction.present? ? render_direction_fragment : render_full_page

          # Кнопка должна быть ПОСЛЕДНЕЙ внутри этого div
          button(id: "new_message_badge",
            class: "hidden fixed bottom-18 right-4 chat chat-end z-50", # right-4 чтобы не прилипало к краю
            data: {
              action: "click->autoscroll#scrollToBottom",
              autoscroll_target: "badge"
            }) do
            div(class: "chat-bubble chat-bubble-secondary flex px-2 min-w-0 shadow-lg cursor-pointer") do
              span { lucide_icon("arrow-down", class: "size-5") }
              span(class: "ml-1 text-xs font-bold") { "новое" }
            end
          end
        end
        # Форма ввода комментария (прижата к низу)
        if current_user
          # reply_controller внутри Form::Create.rb
          div(id: "new_comment_form", class: "flex-none sticky bottom-0 bg-base-100 p-4 pb-safe z-10") do
            render Components::Comments::Form::Create.new(entry: @entry, pagy_has_next: @pagy_has_next, pagy: @pagy)
          end
        end
        # snap-end snap-always Это для залипания
        div(class: "snap-end snap-always") { }
      end
    end
  end

  def render_full_page
    # Frame подгрузки ВВЕРХ
    # if (@highlight_id > 0 && @pagy_has_prev) || (@direction == "prev" && @pagy&.next)
    if @pagy_has_prev || (@pagy && @pagy.page > 1)
      render_load_frame(:prev, @comments.first)
    end

    @comments.each_with_index do |comment, i|
      # Проверка на группу для начальной загрузки
      next_c = @comments[i + 1]
      last = next_c.nil? || next_c.user_id != comment.user_id
      render_comment(comment, last)
    end
    # Frame подгрузки ВНИЗ
    if @pagy&.next || @pagy_has_next || (@highlight_id > 0 && @direction.nil?) || (@highlight_id > 0 && @pagy_has_next) || (@direction == "next" && @pagy&.next)
      render_load_frame(:next, @comments.last)
    end

    if @button_down.present?
      a(
        href: entry_comments_path(@entry),
        class: "fixed bottom-24 right-6 btn btn-circle btn-secondary shadow-xl z-50",
        id: "go_to_latest",
        data: { turbo_frame: "comments", action: "click->autoscroll#disable_click" }
      ) do
        lucide_icon("chevrons-down")
      end
    end
  end

  def render_direction_fragment
    turbo_frame_tag(@frame_id, refresh: "morph") do
      if @direction == "prev"
        render_load_frame(:prev, @comments.first) if @pagy&.next
        @comments.each { |c| render_comment(c, true) }
      end
      if @direction == "next"
        @comments.each { |c| render_comment(c, true) }
        if @comments.size >= 20
          render_load_frame(:next, @comments.last)
        end
      end
    end
  end

  def render_comment(comment, last)
    is_target = (comment.id == @highlight_id)

    target_classes = is_target ? "js-highlighted-comment" : ""
    render Components::Comments::Card.new(entry: comment, is_last_in_group: last, class_target: target_classes) do |card|
      card.card_comment
    end
  end

  def render_load_frame(direction, ref_comment)
    return unless ref_comment

    id = "load_#{direction}_comment_#{ref_comment.id}"

    turbo_frame_tag(id,
      src: entry_comments_path(@entry,
        direction: direction,
        ref_id: ref_comment.id,
        comment_id: (@highlight_id > 0 ? @highlight_id : nil),
        frame_id: id),
      loading: :lazy,
      target: "_top",
      class: "card-comment",
      refresh: "morph") do
      render Components::Pagination::Skeleton.new
    end
  end
end
