class Entries::NotifyFollowedTagsJob < ApplicationJob
  queue_as :default

  def perform(entry_id)
    entry = Entry.includes(:tags, :user).find_by(id: entry_id)

    return unless entry&.entryable_type == "Post"
    return if entry.tag_ids.emtry?
    return if Noticed::Event.exists?(type: "Entries::NewEntryInFollowedTagsNotifier", record: entry)

    recipients = User.joins(:subscriptions).where(subscriptions: { followable_id: entry.tag_ids }).where.not(id: entry.user_id).distinct
    return if recipients.empty?

    tags = entry.tags.limit(3).pluck(:name)
    body = if tags.empty?
      "Новый пост с тэгом на который вы подписаны"
    else
      "Тэги: #{tags.join(', ')}"
    end

    Entries::NewEntryInFollowedTagsNotifier.with(
      record: entry,
      title: "Новый пост по вашим тегам",
      body: body,
      root_entry_id: entry.id
    ).deliver_later(recipients)
  end
end
