class Entries::Streams::UpdateJob < ApplicationJob
  queue_as :default

  def perform(entry_id)
    entry = Entry.find_by(id: entry_id)

    return unless entry

    Turbo::StreamsChannel.broadcast_refresh_to(:entries)

    entry.tags.find_each do |tag|
      Turbo::StreamsChannel.broadcast_refresh_to(:tag, tag.id)
    end

    entry.user.followed_users.find_each do |user|
      Turbo::StreamsChannel.broadcast_refresh_to(:user, user.id)
    end
  end
end
