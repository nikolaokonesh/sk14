# frozen_string_literal: true

class Components::Entries::AfishaBadge < Components::Base
  def initialize(entry:, size: :md)
    @entry = entry
    @size = size # Можно добавить поддержку разных размеров (:sm, :md, :lg)
  end

  def view_template
    state = @entry.afisha_state

    div(class: "flex items-center gap-1") do
      # Основная метка "АФИША"
      span(class: [
        "font-bold uppercase rounded px-1",
        @size == :sm ? "text-[8px]" : "text-[10px]",
        (state == :finished ? "bg-base-content/10 text-base-content/40" : "bg-cyan-500/20 text-cyan-500")
      ]) { "Афиша" }

      # Конкретный статус
      case state
      when :finished
        badge_tag("Прошло #{I18n.l(@entry.event_date, format: "%-d %b")}", class_m: "badge-ghost opacity-50")
      when :ongoing
        badge_tag("Идет сейчас", class_m: "badge-error animate-pulse")
      when :today
        badge_tag("Сегодня в #{@entry.event_date.strftime('%H:%M')}", class_m: "bg-cyan-500/20 text-blue-300 border-none")
      else
        badge_tag(I18n.l(@entry.event_date, format: "%-d %b"), class_m: "bg-cyan-500/20 text-blue-300 border-none")
      end
    end
  end

  private

  def badge_tag(text, class_m: "")
    span(class: [
      "badge font-bold uppercase whitespace-nowrap",
      @size == :sm ? "badge-xs text-[8px] px-1" : "badge-sm text-[10px] px-2",
      class_m
    ]) { text }
  end
end
