class Entries::Streams::CreateJob < ApplicationJob
  queue_as :default

  def perform(entry_id)
    entry = Entry.find_by(id: entry_id)
    return unless entry

    Turbo::StreamsChannel.broadcast_refresh_to(:entries)
  end
end
