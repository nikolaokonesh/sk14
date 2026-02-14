class Entries::Streams::RecoveryJob < ApplicationJob
  queue_as :default

  def perform(entry_id)
    entry = Entry.find_by(id: entry_id)

    Turbo::StreamsChannel.broadcast_replace_to(
      :entries,
      target: "entry_#{entry_id}",
      renderable: Components::Entries::Card.new(entry: entry, highlight: true),
      layout: false
    )
    entry.tags.find_each do |tag|
      Turbo::StreamsChannel.broadcast_replace_to(
        :tag, tag.id,
        target: "entry_#{entry_id}",
        renderable: Components::Entries::Card.new(entry: entry, highlight: true),
        layout: false
      )
    end
    Turbo::StreamsChannel.broadcast_refresh_to(
      :tags
    )
  end
end
