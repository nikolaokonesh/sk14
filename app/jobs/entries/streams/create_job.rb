class Entries::Streams::CreateJob < ApplicationJob
  queue_as :default

  def perform(entry_id)
    entry = Entry.find_by(id: entry_id)
    return unless entry

    Turbo::StreamsChannel.broadcast_render_to(
      :entries,
      renderable: Views::Entries::Streams::Create.new(entry: entry),
      layout: false
    )

    Turbo::StreamsChannel.broadcast_refresh_to(:entries_tags_query)

    entry.tags.find_each do |tag|
      Turbo::StreamsChannel.broadcast_refresh_to(:tag, tag.id)
    end

    entry.user.followed_users.find_each do |user|
      Turbo::StreamsChannel.broadcast_refresh_to(:user, user.id)
    end

    Turbo::StreamsChannel.broadcast_refresh_to(:tags)
  end
end
