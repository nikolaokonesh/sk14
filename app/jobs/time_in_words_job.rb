class TimeInWordsJob < ApplicationJob
  queue_as :default

  def perform
    # Берем с небольшим запасом, чтобы не терять записи на границе 2 часов
    entries = Entry.where(created_at: 2.hours.ago..Time.zone.now)

    return if entries.none?

    entries.find_each do |entry|
      # Разница между сейчас и временем записи
      age_minutes = ((Time.zone.now - entry.created_at) / 60).to_i

      if should_update?(age_minutes)
        Turbo::StreamsChannel.broadcast_update_to(
          :entries,
          target: [ entry, :created_at ],
          renderable: Components::Shared::TimeInWords.new(entry: entry),
          layout: false
        )
        Turbo::StreamsChannel.broadcast_update_to(
          entry,
          target: [ entry, :created_at ],
          renderable: Components::Shared::TimeInWords.new(entry: entry),
          layout: false
        )
      end
    end
  end

  private

  def should_update?(age_minutes)
    case
    when age_minutes <= 10
      true
    when age_minutes < 120
      (age_minutes % 5).zero?
    else
      false
    end
  end
end
