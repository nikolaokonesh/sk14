# frozen_string_literal: true

class Components::Entries::AfishaSection < Components::Base
  def initialize(afishas:)
    @afishas = afishas # Здесь лежат объекты Entry
  end

  def view_template
    return if @afishas.empty?

    div(class: "mb-6 mt-2") do
      div(class: "flex items-center justify-between px-4 mb-3") do
        h2(class: "text-xl font-black tracking-tight flex items-center gap-2") do
          plain raw lucide_icon("calendar-range", class: "text-primary size-5")
          plain "Афиша"
        end
        span(class: "badge badge-primary badge-sm font-bold") { @afishas.size }
      end

      div(class: "flex overflow-x-auto snap-x snap-mandatory no-scrollbar gap-4 px-4 pb-4") do
        @afishas.each { |entry| render_afisha_card(entry) }
      end
    end
  end

  private

  def render_afisha_card(entry)
    # Используем afisha_state, который делегирован из Entry в Post
    state = entry.afisha_status&.to_sym || :upcoming
    is_finished = (state == :finished)

    a(href: entry_path(entry), class: [
          "snap-center shrink-0 w-56 bg-base-200 rounded-lg p-4 shadow-sm border relative overflow-hidden transition-all active:scale-95 hover:border-primary/50 group block",
          (is_finished ? "opacity-50 grayscale-[0.5] border-base-300" : "border-base-300")
        ]) do
      div(class: "absolute top-0 right-0 z-20") do
        # Бейдж умеет работать с Post, поэтому передаем entry.entryable
        render Components::Entries::AfishaBadge.new(entry: entry.entryable, size: :sm)
      end

      div(class: "flex flex-col gap-2") do
        div(class: "flex items-center justify-between mt-1") do
          div(class: [ "flex items-center gap-1", (is_finished ? "opacity-30" : "text-primary") ]) do
            plain raw lucide_icon("clock", size: 12)
            # event_date также делегирован в Entry
            span(class: "text-[11px] font-black tracking-widest") { entry.event_date&.strftime("%H:%M") }
          end

          if !is_finished
            # duration_text НЕ делегирован, идем через entryable
            span(class: "text-[10px] font-bold opacity-40") { entry.entryable.duration_text }
          end
        end

        div(class: [
          "font-black leading-tight line-clamp-3 text-sm transition-colors",
          (is_finished ? "text-base-content/40" : "text-base-content/90 group-hover:text-primary")
        ]) do
          # title — это метод самого Entry
          plain entry.title.presence || "Событие"
        end
      end
    end
  end
end
