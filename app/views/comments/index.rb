# frozen_string_literal: true

class Views::Comments::Index < Components::Base
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

  def view_template
    turbo_frame_tag :comments, refresh: "morph" do
      turbo_stream_from [ @entry, :comments ]

      div(data: { controller: "reply" }) do
        # Контейнер:
        # 1. Убрали action: "turbo:frame-load...", так как сделали setTimeout в JS
        # 2. relative нужен для позиционирования кнопки
        div(id: dom_id(@entry.root, :comments_list),
            class: "pt-4 h-[71svh] overflow-y-auto overflow-x-visible no-scrollbar",
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

          if @button_down.present?
            a(
              href: entry_comments_path(@entry),
              class: "fixed bottom-24 right-6 btn btn-circle btn-secondary shadow-xl z-50",
              id: "go_to_latest",
              data: {
                turbo_frame: "comments",
                action: "click->autoscroll#disable_click"
              }
            ) { lucide_icon("chevrons-down") }
          end
        end
        # Форма ввода комментария (прижата к низу)
        if current_user
          # reply_controller внутри Form::Create.rb
          div(id: "new_comment_form", class: "flex-none sticky bottom-0 bg-base-100 p-4 pb-safe z-10") do
            render Components::Comments::Form::Create.new(entry: @entry, has_next: @has_next, pagy: @pagy)
          end
        end
        # snap-end snap-always Это для залипания
        div(class: "snap-end") { }
      end
    end
  end

  def render_full_page
    # Frame подгрузки ВВЕРХ
    # if (@highlight_id > 0 && @has_prev) || (@direction == "prev" && @pagy&.next)
    if @has_prev || (@pagy && @pagy.page > 1)
      render_load_frame(:prev, @comments.first)
    end

    comment_groups = @comments.chunk { |c| c.user_id }.to_a

    comment_groups.each_with_index do |(user_id, group), index|
      # Проверка на группу для начальной загрузки
      is_last_group = (index == comment_groups.size - 1) && !@has_next
      render_group(user_id, group, is_last_group)
    end
    # Frame подгрузки ВНИЗ
    if @pagy&.next || @has_next
      render_load_frame(:next, @comments.last)
    end
  end

  private

  def render_group(user_id, group, is_last_group)
    group_starter_id = dom_id(group.first)
    group_wrapper_id = "group_#{group_starter_id}"
    bubbles_id = "bubbles_container_#{group_starter_id}"
    div(id: group_wrapper_id, data: { controller: "chat-visibility", chat_visibility_target: "chat", auth_visibility_author_id_value: user_id },
        class: "chat chat-start comment-card group items-end m-1") do
      div(class: "chat-image avatar self-stretch flex items-end") do
        div(class: "w-10 rounded-full sticky bottom-2 transition-all") do
          render Components::Users::Avatar.new(user: group.first.user)
        end
      end
      div(
        id: bubbles_id,
        class: "chat-bubble bg-base-300 p-0 max-w-[99%] flex flex-col gap-0.5"
      ) do
        group.each_with_index do |comment, i|
          is_first = (i == 0)
          is_last = (i == group.size - 1)
          is_the_very_last = is_last_group && is_last

          render_comment(comment, is_first, is_last, is_the_very_last)
        end
      end
    end
  end

  def render_direction_fragment
    turbo_frame_tag(@frame_id, refresh: "morph") do
      comment_groups = @comments.chunk { |c| c.user_id }.to_a

      if @direction == "prev"
        render_load_frame(:prev, @comments.first) if @pagy&.next
        comment_groups.each do |user_id, group|
          render_group(user_id, group, false)
        end
      end
      if @direction == "next"
        comment_groups.each_with_index do |(user_id, group), index|
          is_last_in_fragment = (index == comment_groups.size - 1)
          is_the_very_last_group = is_last_in_fragment && !@has_next

          render_group(user_id, group, is_the_very_last_group)
        end
        if @comments.size >= 20
          render_load_frame(:next, @comments.last)
        end
      end
    end
  end

  def render_comment(comment, is_first, is_last, is_the_very_last)
    is_target = (comment.id == @highlight_id)
    is_the_very_last_classes = is_the_very_last ? "last-comment" : ""
    target_classes = is_target ? "js-highlighted-comment" : ""

    render Components::Comments::Card.new(
      entry: comment,
      is_first: is_first,
      is_last: is_last,
      class_target: "#{target_classes} #{is_the_very_last_classes}"
    ) do |card|
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
