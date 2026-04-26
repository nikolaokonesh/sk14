class TimeInWordsJob < ApplicationJob
  queue_as :default

  def perform
    # Ограничиваем выборку только теми, кому реально нужно обновлять "минуты"
    # Те, кто старше 2-3 часов, обычно уже имеют статичную дату (например, "9 мая")
    entries = Entry.where("created_at >= ?", 3.hours.ago)

    entries.find_each do |entry|
      # Вычисляем текущее "время словами"
      current_words = ActionController::Base.helpers.time_ago_in_words(entry.created_at)

      # Ключ в кэше, чтобы помнить, что мы уже отправляли
      cache_key = "entry_#{entry.id}_time_words"
      last_sent_words = Rails.cache.read(cache_key)

      # Отправляем Broadcast ТОЛЬКО если текст изменился
      if current_words != last_sent_words
        broadcast_time_update(entry)

        # Запоминаем новый текст в кэш на 1 час
        Rails.cache.write(cache_key, current_words, expires_in: 1.hour)
      end
    end
  end

  private

  def broadcast_time_update(entry)
    # Стрим для общего списка
    Turbo::StreamsChannel.broadcast_update_to(
      :entries,
      target: "created_at_entry_#{entry.id}",
      renderable: Components::Shared::TimeInWords.new(entry: entry)
    )

    # Стрим для страницы Show (если там другой таргет)
    Turbo::StreamsChannel.broadcast_update_to(
      entry,
      target: "created_at_entry_#{entry.id}",
      renderable: Components::Shared::TimeInWords.new(entry: entry)
    )
  end
end
