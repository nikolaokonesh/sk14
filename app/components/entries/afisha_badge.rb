# frozen_string_literal: true

class Components::Entries::AfishaBadge < Components::Base
  def initialize(entry:, size: :md)
    @entry = entry # Здесь может быть Post или Advertisement
    @size = size
  end

  def view_template
    # 1. ЗАЩИТА: Если это не афиша, вообще ничего не рисуем
    return unless @entry.respond_to?(:is_afisha?) && @entry.is_afisha?

    # 2. ЗАЩИТА: Если нет даты, мы не сможем ничего отрендерить
    return if @entry.event_date.blank?

    # Читаем статус
    state = @entry.afisha_status&.to_sym || :upcoming

    div(class: "flex items-center gap-1") do
      # Основная метка "АФИША"
      span(class: [
        "font-bold tracking-widest uppercase rounded px-1",
        @size == :sm ? "text-[8px]" : "text-[10px]",
        (state == :finished ? "bg-base-content/10 text-base-content/40" : "bg-cyan-500/20 text-cyan-500")
      ]) { "Афиша" }

      # Конкретный статус
      case state
      when :finished
        badge_tag("Прошло #{l_date(@entry.event_date)}", class_m: "badge-ghost opacity-50")
      when :ongoing
        badge_tag("Идет сейчас", class_m: "badge-error animate-pulse")
      when :today
        badge_tag("Сегодня в #{@entry.event_date.strftime('%H:%M')}", class_m: "bg-cyan-500/20 text-blue-500 border-none")
      else
        # :upcoming
        badge_tag(l_date(@entry.event_date), class_m: "bg-cyan-500/20 text-blue-500 border-none")
      end
    end
  end

  private

  # Вспомогательный метод для безопасной локализации
  def l_date(date)
    return "" if date.blank?
    I18n.l(date, format: "%-d %b")
  end

  def badge_tag(text, class_m: "")
    span(class: [
      "badge tracking-widest font-bold uppercase whitespace-nowrap",
      @size == :sm ? "badge-xs text-[8px] px-1" : "badge-sm text-[10px] px-2",
      class_m
    ]) { text }
  end
end
