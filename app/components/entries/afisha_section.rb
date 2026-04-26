# frozen_string_literal: true

class Components::Entries::AfishaSection < Components::Base
  def initialize(afishas:)
    @afishas = afishas
  end

  def view_template
    # Получаем активные афиши
    return if @afishas.empty?

    div(class: "mb-6 mt-2") do
      div(class: "flex items-center justify-between px-4 mb-3") do
        h2(class: "text-xl font-black tracking-tight flex items-center gap-2") do
          plain raw lucide_icon("calendar-range", class: "text-primary size-5")
          plain "Афиша"
        end
        span(class: "badge badge-primary badge-sm font-bold") { @afishas.size }
      end

      # Горизонтальный скролл для мобилок
      div(class: "flex overflow-x-auto snap-x snap-mandatory no-scrollbar gap-4 px-4 pb-4") do
        @afishas.each do |post|
          render_afisha_card(post)
        end
      end
    end
  end

  private

  def render_afisha_card(post)
    # 1. Используем Time.zone.parse — он прочитает "13:00" как 13:00 вашего города
    start_date = Time.zone.parse(post.event_date) rescue Time.current

    duration   = post.event_duration.to_i
    duration   = 1 if duration < 1
    end_date   = start_date + duration.days

    now = Time.current

    # 2. Логика переключения
    is_ongoing        = now >= start_date && now <= end_date
    is_upcoming_today = now.to_date == start_date.to_date && now < start_date

    # --- ВЕРСТКА КАРТОЧКИ ---
    div(class: "snap-center shrink-0 w-64 bg-base-200 rounded-3xl p-4 shadow-sm border border-base-300 relative overflow-hidden transition-all active:scale-95 hover:border-primary/50") do
      # ПРАВЫЙ ВЕРХНИЙ УГОЛ: Бейджи статуса
      div(class: "absolute top-0 right-0 overflow-hidden flex") do
        if is_ongoing
          # ПУЛЬСИРУЮЩИЙ КРАСНЫЙ: когда время наступило или событие в процессе
          div(class: "bg-error text-error-content px-3 py-1.5 rounded-bl-2xl font-black text-[10px] uppercase flex items-center gap-2 shadow-lg shadow-error/20") do
            span(class: "relative flex h-2 w-2") do
              span(class: "animate-ping absolute inline-flex h-full w-full rounded-full bg-white opacity-75")
              span(class: "relative inline-flex rounded-full h-2 w-2 bg-white")
            end
            plain "Началось"
          end
        elsif is_upcoming_today
          # ЖЕЛТЫЙ: только если сегодня, но время еще НЕ пришло
          div(class: "bg-warning text-warning-content px-3 py-1.5 rounded-bl-2xl font-black text-[10px] uppercase shadow-lg shadow-warning/20") do
            plain "Сегодня"
          end
        else
          # СИНИЙ: стандартная дата для будущих дней
          div(class: "bg-primary text-primary-content px-3 py-1.5 rounded-bl-2xl font-black text-xs shadow-lg shadow-primary/20") do
            plain I18n.l(start_date, format: "%-d %b")
          end
        end
      end

      # ОСНОВНОЙ КОНТЕНТ
      div(class: "flex flex-col gap-3 mt-2") do
        # Первая строка: Время и флаг длительности
        div(class: "flex items-center justify-between") do
          div(class: "flex items-center gap-1 text-primary") do
            plain raw lucide_icon("clock", size: 14)
            span(class: "text-xs font-black tracking-widest") { start_date.strftime("%H:%M") }
          end

          if duration > 1
            span(class: "badge badge-ghost badge-sm text-[10px] font-bold opacity-60 px-2") do
              # Короткое обозначение длительности
              plain "#{duration} дн."
            end
          end
        end

        # Вторая строка: Заголовок поста
        div(class: "font-black leading-tight line-clamp-3 min-h-[2.5rem] text-sm text-base-content/90") do
          # Берем заголовок из связанной записи Entry
          plain post.entry.title.presence || "Событие"
        end

        # Третья строка: Кнопка действия
        a(href: entry_path(post.entry),
          class: "btn btn-sm btn-primary w-full rounded-xl mt-1 border-none hover:text-primary-content group transition-all") do
          span(class: "text-[11px] font-bold uppercase tracking-wider") { "Подробнее" }
          plain raw lucide_icon("arrow-right", class: "size-3 transition-transform group-hover:translate-x-1")
        end
      end
    end
  end
end
