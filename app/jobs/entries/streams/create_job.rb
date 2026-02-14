class Entries::Streams::CreateJob < ApplicationJob
  queue_as :default

  def perform(entry_id)
    entry = Entry.find_by(id: entry_id)

    Turbo::StreamsChannel.broadcast_render_to(
      :entries,
      renderable: Views::Entries::Streams::Create.new(entry: entry),
      layout: false
    )
    entry.tags.find_each do |tag|
      Turbo::StreamsChannel.broadcast_prepend_to(
        :tag, tag.id,
        target: :entries,
        renderable: Components::Entries::Card.new(entry: entry, highlight: true),
        layout: false
      )
    end
    entry.user.followed_users.find_each do |user|
      Turbo::StreamsChannel.broadcast_prepend_to(
        :user, user.id,
        target: :entries,
        renderable: Components::Entries::Card.new(entry: entry, highlight: true),
        layout: false
      )
    end
    Turbo::StreamsChannel.broadcast_refresh_to(
      :tags
    )
  end
end
