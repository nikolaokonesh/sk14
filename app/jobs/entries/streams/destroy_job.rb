class Entries::Streams::DestroyJob < ApplicationJob
  queue_as :default

  def perform(entry_id)
    entry = Entry.find_by(id: entry_id)

    Turbo::StreamsChannel.broadcast_render_to(
      :entries,
      renderable: Views::Entries::Streams::Destroy.new(entry: entry),
      layout: false
    )
    entry.tags.find_each do |tag|
      Turbo::StreamsChannel.broadcast_remove_to(
        :tag, tag.id,
        target: "entry_#{entry_id}"
      )
    end
    Turbo::StreamsChannel.broadcast_refresh_to(
      :tags
    )
  end
end
