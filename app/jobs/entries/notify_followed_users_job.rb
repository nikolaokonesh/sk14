class Entries::NotifyFollowedUsersJob < ApplicationJob
  queue_as :default

  def perform(entry_id)
    entry = Entry.includes(:user).find_by(id: entry_id)
    return unless entry&.entryable_type == "Post"

    recipients = entry.user.followers.where.not(id: entry.user_id)
    retirn if recipients.empty?

    Entries::NewEntryInFollowedUserNotifier.with(
      record: entry,
      title: "Новый пост от #{ entry.user.username }",
      body: "Пользователь опублтиковал новый пост",
      root_entry_id: entry.id
    ).deliver_later(recipients)
  end
end
