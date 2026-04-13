class RelativeTimeInWordsJob < ApplicationJob
  queue_as :default

  MAX_PROCESS_TIME = 1.hour

  def perform(entry_id)
    entry = Entry.find_by(id: entry_id)
    return if entry.nil? || (Time.current - entry.created_at) > MAX_PROCESS_TIME

    Turbo::StreamsChannel.broadcast_update_to(
      "created_at_#{entry.id}",
      target: "created_at_#{entry.id}",
      renderable: Components::Shared::RelativeTimeInWords.new(entry: entry),
      layout: false
    )

    # Schedule next update
    self.class.set(wait: update_interval(entry)).perform_later(entry)
  end

  private

  def update_interval(entry)
    age = Time.current - entry.created_at

    case
    when age <= 10.minutes
      1.minute
    else
      5.minutes
    end
  end
end
