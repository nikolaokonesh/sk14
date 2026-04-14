class RelativeTimeInWordsJob < ApplicationJob
  queue_as :default

  def perform
    entries = Entry.where("created_at >= ?", 1.hour.ago)

    entries.find_each do |entry|
      age_minutes = ((Time.current - entry.created_at) / 60).to_i

      if should_update?(age_minutes)
        Turbo::StreamsChannel.broadcast_update_to(
          [:entry, entry.id],
          target: "created_at_#{entry.id}",
          renderable: Components::Shared::RelativeTimeInWords.new(entry: entry),
          layout: false
        )

        Turbo::StreamsChannel.broadcast_update_to(
          :entries_index,
          target: "created_at_#{entry.id}",
          renderable: Components::Shared::RelativeTimeInWords.new(entry: entry),
          layout: false
        )
      end
    end
  end

  private

  def should_update?(age_minutes)
    case
    when age_minutes < 10
      true
    when age_minutes < 60
      (age_minutes % 5).zero?
    else
      false
    end
  end
end
