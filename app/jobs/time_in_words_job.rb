class TimeInWordsJob < ApplicationJob
  queue_as :default

  # Защита на уровне Solid Queue: только один такой джоб в очереди одновременно
  limits_concurrency key: -> { "time_in_words_singleton" }, duration: 50.seconds

  def perform
    now = Time.current

    # Защита 1: Собираем ID всех записей, которые подлежат обновлению
    # Если новых записей нет и минута не кратна 5 или 30 — выходим сразу
    fresh_entries = Entry.where(created_at: 11.minutes.ago..now)

    # Если нет совсем свежих, и время не "кратное", то делать нечего
    is_5_min_tick = (now.min % 5 == 0)
    is_30_min_tick = (now.min % 30 == 0)

    return if fresh_entries.none? && !is_5_min_tick && !is_30_min_tick

    # --- Далее идет основная логика ---

    # Свежие (до 10-11 мин) обновляем всегда
    fresh_entries.find_each { |e| broadcast_time(e) }

    # Средние (11-60 мин) — только в 0, 5, 10... минут
    if is_5_min_tick
      Entry.where(created_at: 1.hour.ago..11.minutes.ago).find_each { |e| broadcast_time(e) }
    end

    # Старые (1-3 часа) — только в 0 и 30 минут
    if is_30_min_tick
      Entry.where(created_at: 3.hours.ago..1.hour.ago).find_each { |e| broadcast_time(e) }
    end
  end

  private

  def broadcast_time(entry)
    # Защита 2: Проверка на существование записи перед отправкой (на случай удаления)
    return unless entry.present?

    Turbo::StreamsChannel.broadcast_update_to(
      :entries,
      target: "created_at_entry_#{entry.id}",
      html: ActionController::Base.helpers.time_ago_in_words(entry.created_at)
    )
  end
end
