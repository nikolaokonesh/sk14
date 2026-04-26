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
        render Components::Shared::BgGradient.new(opacity: "opacity-30")

        # Основная карточка
        div(class: "relative bg-base-200/70 rounded-2xl shadow-xl overflow-hidden") do
          render_afisha_status if @entry.entryable.is_afisha?

          div(class: "p-4") do
            div(class: "lexxy-show text-lg leading-relaxed prose prose-stone max-w-none") { @entry.content.to_s }
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

  def render_afisha_status
    post = @entry.entryable
    start_date = Time.zone.parse(post.event_date) rescue nil
    return unless start_date

    duration = post.event_duration.to_i
    # Считаем дату окончания
    end_date = start_date + (duration > 0 ? duration : 1).days
    now = Time.current

    # ЛОГИКА СТАТУСОВ
    is_finished      = now > end_date
    is_ongoing       = now >= start_date && now <= end_date
    is_upcoming_today = now.to_date == start_date.to_date && now < start_date

    div(class: "w-full p-4 pb-0") do
      # Если событие прошло, делаем контейнер более тусклым (opacity-70)
      div(class: [ "flex items-center gap-3 p-3 rounded-xl bg-base-300/50 border border-white/5", ("opacity-70" if is_finished) ]) do
        if is_finished
          # СТАТУС: ЗАКОНЧИЛОСЬ
          div(class: "flex items-center gap-2 bg-base-content/10 text-base-content/50 px-3 py-1 rounded-lg border border-base-content/20") do
            plain raw lucide_icon("calendar-x", size: 14)
            span(class: "text-xs font-black uppercase") { "Событие завершено" }
          end
        elsif is_ongoing
          # СТАТУС: ИДЕТ СЕЙЧАС
          div(class: "flex items-center gap-2 bg-error/20 text-error px-3 py-1 rounded-lg border border-error/30 animate-pulse") do
            span(class: "relative flex h-2 w-2") do
              span(class: "animate-ping absolute inline-flex h-full w-full rounded-full bg-error opacity-75")
              span(class: "relative inline-flex rounded-full h-2 w-2 bg-error")
            end
            span(class: "text-xs font-black uppercase") { "Идет сейчас" }
          end
        elsif is_upcoming_today
          # СТАТУС: СЕГОДНЯ
          div(class: "bg-warning/20 text-warning px-3 py-1 rounded-lg border border-warning/30 text-xs font-black uppercase") do
            plain "Сегодня"
          end
        else
          # СТАТУС: БУДУЩАЯ ДАТА
          div(class: "bg-primary/20 text-primary px-3 py-1 rounded-lg border border-primary/30 text-xs font-black uppercase") do
            plain I18n.l(start_date, format: "%-d %b")
          end
        end

        # ДЕТАЛИ ВРЕМЕНИ (скрываем время, если событие уже совсем старое, или оставляем для инфо)
        div(class: "flex flex-col") do
          span(class: [ "text-sm font-black", ("line-through opacity-30" if is_finished) ]) do
            start_date.strftime("%H:%M")
          end
          if duration > 1
            span(class: "text-[10px] opacity-50 font-bold uppercase") { "Длительность: #{duration} дн." }
          end
        end
      end
    end
  end
end
