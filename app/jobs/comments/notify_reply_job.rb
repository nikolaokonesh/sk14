class Comments::NotifyReplyJob < ApplicationJob
  queue_as :default

  def perform(comment_id)
    comment = Comment.includes(entry: :parent).find_by(id: comment_id)
    return unless comment&.entry

    parent_entry = comment.entry.parent
    return unless parent_entry&.entryable_type == "Comment"
    return if parent_entry.user_id == comment.entry.user_id

    Comments::NewReplyNotifier.with(
      record: comment.entry.root,
      title: "Новый ответ на ваш комментарий",
      body: "#{comment.entry.user.username} ответил(а) вам",
      root_entry_id: comment.entry.root_id
    ).deliver_later(parent_entry.user)
  end
end
