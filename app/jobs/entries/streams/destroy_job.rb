class Entries::Streams::DestroyJob < ApplicationJob
  queue_as :default

  def perform(entry_id = nil)
    entry = entry_id.present? ? Entry.find_by(id: entry_id) : nil

    return if entry.blank?

    Turbo::StreamsChannel.broadcast_refresh_to(:entries)
  end
end
