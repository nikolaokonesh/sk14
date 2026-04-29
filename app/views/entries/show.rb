# frozen_string_literal: true

class Views::Entries::Show < Views::Base
  def initialize(entry:)
    @entry = entry
  end

  def view_template
    turbo_stream_from(@entry)

    div(class: "py-4") do
      # --- БЛОК АВТОРА И МЕТА-ДАННЫХ ---
      div(class: "flex items-center text-lg px-2") do
        span(class: "mr-2 font-bold") { @entry.user.username(:full) }
        span(class: "text-xs opacity-60") { render Components::Shared::CreatedAt.new(entry: @entry) }

        if show_read_state_badge?
          turbo_frame_tag "read", src: entry_path(@entry), class: "opacity-0 w-0", loading: :lazy
        end

        # Кнопки управления (Редактировать / Удалить)
        render_management_dropdown if authenticated? && can?(:manage, @entry)
      end

      # Теги (категории)
      div(class: "p-2") do
        render Components::Entries::TagBadge.new(entry: @entry)
      end

      # --- ОСНОВНОЙ КОНТЕНТ ПОСТА ---
      div(class: "relative") do
        render Components::Shared::BgGradient.new(opacity: "opacity-30")

        div(class: "relative bg-base-200/70 rounded-2xl shadow-xl overflow-hidden") do
          # Если это афиша — рендерим специальный блок статуса
          render_afisha_status if @entry.entryable.is_afisha?

          div(class: "p-4") do
            # Тело поста (Rich Text)
            div(class: "lexxy-show text-lg leading-relaxed prose prose-stone max-w-none") { @entry.content.to_s }

            # Плашка "Без комментариев", если отключены
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

  # Блок с деталями афиши (время, статус, кнопка завершения)
  def render_afisha_status
    post = @entry.entryable
    state = post.afisha_state
    is_finished = (state == :finished)

    div(class: "w-full p-4 pb-0") do
      div(class: [
        "flex flex-wrap items-center gap-3 p-3 rounded-xl bg-base-300/50 border border-white/5",
        ("opacity-70" if is_finished)
      ]) do
        # 1. Используем наш новый универсальный бейдж
        render Components::Entries::AfishaBadge.new(entry: post, size: :md)

        # 2. Информация о времени (используем методы модели)
        div(class: "flex flex-col") do
          span(class: [ "text-sm font-black tracking-tight", ("line-through opacity-30" if is_finished) ]) do
            "#{post.event_date.strftime('%H:%M')} — #{post.end_date.strftime('%H:%M')}"
          end
          span(class: "text-[10px] opacity-50 font-bold uppercase") do
            "Длительность: #{post.duration_text}"
          end
        end

        # 3. Кнопка управления для автора
        render_afisha_toggle_button(post)
      end
    end
  end

  # Кнопка "Завершить / Возобновить" для автора
  def render_afisha_toggle_button(post)
    return unless authenticated? && can?(:update, @entry)

    state = post.afisha_state
    # Кнопку показываем, если событие уже идет или уже завершено (чтобы возобновить)
    if state == :ongoing || post.manual_finished?
      manually = post.manual_finished?

      div(class: "ml-auto") do
        button_to entry_path(@entry),
                  params: {
                    entry: {
                      entryable_attributes: {
                        id: post.id,
                        manual_finished: !manually,
                        # Если возобновляем — возвращаем расчетное время окончания
                        finished_at: (!manually ? Time.current : post.end_date)
                      }
                    }
                  },
                  method: :patch,
                  class: [ "btn btn-xs rounded-lg shadow-sm", (manually ? "btn-success" : "btn-outline btn-error") ],
                  data: { turbo_confirm: (manually ? "Возобновить мероприятие?" : "Завершить событие досрочно?") } do
          manually ? "Возобновить" : "Завершить"
        end
      end
    end
  end

  # Логика показа бейджа "не прочитано"
  def show_read_state_badge?
    return false unless current_user
    return false if @entry.user == current_user
    return false if Current.user.post_read_for?(@entry)
    return false unless @entry.post?
    true
  end

  # Вынес дропдаун в отдельный метод для чистоты view_template
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
