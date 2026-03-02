class Comments::NotifyMentionsJob < ApplicationJob
  queue_as :default

  def perform(comment_id)
    comment = Comment.includes(entry: :user).find_by(id: comment_id)
    return unless comment&.entry

    recipients = mention_recipients(comment)

    return if recipients.empty?

    Comments::NewMentionNotifier.with(
      record: comment.entry.root,
      title: "Вас упомянули в комментарии",
      body: "#{comment.entry.user.username} упомянул(а) вас",
      root_entry_id: comment.entry.root_id
    ).deliver_later(recipients)
  end

  private

  def mention_recipients(comment)
    mentioned_ids = comment.mentioned_user_ids
    return User.none if mentioned_ids.empty?

    User.where(id: mentioned_ids).where.not(id: comment.entry.user_id)
  end
end
