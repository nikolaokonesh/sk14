# frozen_string_literal: true

class Components::Entries::AfishaSection < Views::Base
  def initialize(entries:)
    @entries = entries
  end

  def view_template
    return if @entries.blank?

    section(class: "mb-8") do
      # Заголовок раздела
      div(class: "flex items-center justify-between px-4 mb-3") do
        h2(class: "text-lg font-black uppercase tracking-tight flex items-center gap-2") do
          plain raw lucide_icon("calendar-range", class: "text-cyan-500 size-5")
          span { "Афиша событий" }
        end
        # Можно добавить ссылку "Все", если будет отдельная страница
        span(class: "text-xs opacity-50 font-bold") { "Ближайшая неделя" }
      end

      # Контейнер для скролла
      div(class: "flex gap-3 overflow-x-auto pb-4 px-4 snap-x scrollbar-hide") do
        @entries.each { |entry| render_card(entry) }
      end
    end
  end

  private

  def render_card(entry)
    post = entry.entryable
    start_date = post.event_date.to_date
    # Рассчитываем дату окончания на основе длительности
    duration = post.event_duration.to_i > 0 ? post.event_duration.to_i : 1
    end_date = start_date + (duration - 1).days

    today = Date.current

    # Определяем статус для бейджа
    status_text = nil
    status_class = ""

    if today < start_date
      days_to = (start_date - today).to_i
      status_text = days_to == 1 ? "Завтра" : "через #{days_to} дн."
      status_class = "bg-base-300 text-base-content"
    elsif today >= start_date && today <= end_date
      status_text = "Идёт сейчас"
      status_class = "bg-cyan-500 text-white animate-pulse"
    end

    # Карточка
    a(href: entry_path(entry), class: "snap-start shrink-0 w-64 group") do
      div(class: "card bg-base-200 border border-base-300 shadow-sm group-hover:border-cyan-500/50 transition-colors") do
        div(class: "p-4 space-y-3") do
          # Дата и статус
          div(class: "flex items-start justify-between") do
            div(class: "flex flex-col") do
              span(class: "text-2xl font-black text-cyan-500 leading-none") { start_date.day }
              span(class: "text-xs font-bold uppercase opacity-60") { l(start_date, format: "%b") }
            end

            if status_text
              span(class: "badge badge-xs font-bold p-2 #{status_class}") { status_text }
            end
          end

          # Заголовок
          h3(class: "font-bold text-sm line-clamp-2 min-h-[40px] group-hover:text-cyan-500 transition-colors") do
            entry.title
          end

          # Инфо о длительности
          if duration > 1
            div(class: "flex items-center gap-1 text-[10px] font-bold opacity-40 uppercase") do
              plain raw lucide_icon("clock", size: 12)
              span { "Длительность: #{duration} #{Russian.p(duration, 'день', 'дня', 'дней')}" }
            end
          end
        end
      end
    end
  end
end
