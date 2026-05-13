# frozen_string_literal: true

class Views::Entries::Show < Views::Base
  def initialize(entry:)
    @entry = entry
  end

  def view_template
    turbo_stream_from(@entry)

    div(class: "py-4 mb-10") do
      # --- БЛОК АВТОРА И МЕТА-ДАННЫХ ---
      div(class: "flex items-center text-lg px-2") do
        # username(:full) теперь подгружен через includes(user: :roles)
        span(class: "mr-2 font-bold") { @entry.user.username(:full) }
        span(class: "text-xs opacity-60") { render Components::Shared::CreatedAt.new(entry: @entry) }

        if show_read_state_badge?
          turbo_frame_tag "read", src: entry_path(@entry), class: "opacity-0 w-0 h-0", loading: :lazy
        end

        render_management_dropdown if authenticated? && can?(:manage, @entry)
      end

      div(class: "p-2") do
        render Components::Entries::TagBadge.new(entry: @entry)
      end

      # --- ОСНОВНОЙ КОНТЕНТ ПОСТА ---
      div(class: "relative") do
        render Components::Shared::BgGradient.new(opacity: "opacity-30")

        div(class: "relative bg-base-200/70 rounded-2xl shadow-xl overflow-hidden mb-10") do
          render_afisha_status if @entry.entryable.is_afisha?

          div(class: "p-4") do
            # Используем raw, чтобы ActionText вывел HTML без лишних запросов (т.к. мы сделали includes)
            div(class: "lexxy-show text-lg leading-relaxed prose prose-stone max-w-none") do
              raw @entry.content.to_s
            end
          end
        end
      end

      if @entry.entryable.no_comments?
        p(class: "text-sm italic opacity-50 text-center") { "Без комментариев" }
      end
    end
  end

  private

  def render_afisha_status
    post = @entry.entryable
    state = post.afisha_status&.to_sym
    is_finished = (state == :finished)

    div(class: "w-full p-4 pb-0") do
      div(class: [
        "flex flex-wrap items-center gap-3 p-3 rounded-xl bg-base-300/50 border border-white/5",
        ("opacity-70" if is_finished)
      ]) do
        render Components::Entries::AfishaBadge.new(entry: post, size: :md)

        div(class: "flex flex-col") do
          span(class: [ "text-sm font-black tracking-tight", ("line-through opacity-30" if is_finished) ]) do
            "#{post.event_date.strftime('%H:%M')} — #{post.end_date.strftime('%H:%M')}"
          end
          span(class: "text-[10px] opacity-50 font-bold uppercase") do
            "Длительность: #{post.duration_text}"
          end
        end

        render_afisha_toggle_button(post)
      end
    end
  end

  def render_afisha_toggle_button(post)
    return unless authenticated? && can?(:update, @entry)

    state = post.afisha_status&.to_sym
    if state == :ongoing || post.manual_finished?
      manually = post.manual_finished?

      div(class: "ml-auto") do
        form_with(url: entry_path(@entry), method: :patch, class: "inline") do |f|
          f.hidden_field "entry[entryable_attributes][id]", value: post.id
          f.hidden_field "entry[entryable_attributes][manual_finished]", value: !manually
          f.hidden_field "entry[entryable_attributes][finished_at]", value: (!manually ? Time.current : post.end_date)

          f.submit(manually ? "Возобновить" : "Завершить",
                   class: [ "btn btn-xs rounded-lg shadow-sm", (manually ? "btn-success" : "btn-outline btn-error") ],
                   data: { turbo_confirm: (manually ? "Возобновить мероприятие?" : "Завершить событие досрочно?") })
        end
      end
    end
  end

  def show_read_state_badge?
    user = current_user
    return false unless user
    return false if @entry.user_id == user.id
    !user.post_read_for?(@entry)
  end

  def render_management_dropdown
    div(class: "dropdown dropdown-end ml-auto") do
      div(tabindex: 0, role: "button", class: "px-2 cursor-pointer opacity-50 hover:opacity-100") { raw lucide_icon("ellipsis") }
      ul(tabindex: -1, class: "dropdown-content menu bg-base-300 rounded-box z-[100] p-2 shadow-xl border border-white/5") do
        div(class: "flex gap-2") do
          if can?(:update, @entry)
            a(href: edit_entry_path(@entry), class: "btn btn-square btn-sm btn-success") { raw lucide_icon("pencil", size: 16) }
          end

          if @entry.trash?
            if can?(:restore, @entry)
              a(href: trash_path(@entry, format: :html),
                data: { turbo_method: :put, turbo_confirm: "Восстановить пост?" },
                class: "btn btn-square btn-sm btn-warning") { raw lucide_icon("rotate-ccw", size: 16) }
            end
          else
            a(href: entry_path(@entry, format: :html),
              data: {
                turbo_method: :delete,
                turbo_confirm: (current_user&.has_role?(:admin) && @entry.user_id != current_user.id ? "Удалить навсегда?" : "Удалить в корзину?")
              },
              class: "btn btn-square btn-sm btn-error") { raw lucide_icon("trash", size: 16) }
          end
        end
      end
    end
  end
end
