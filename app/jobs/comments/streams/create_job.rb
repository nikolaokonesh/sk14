class Comments::Streams::CreateJob < ApplicationJob
  queue_as :default

  def perform(comment_id)
    comment = Comment.includes(entry: :root).find_by(id: comment_id)
    return unless comment&.entry

    comment.broadcast_render_to(
      [ comment.entry.root, :comments ],
      renderable: Views::Comments::Streams::Create.new(entry: comment.entry),
      layout: false
    )

    broadcast_read_state_badges(comment.entry.root)
    broadcast_comments_counter(comment.entry.root)
  end

  private

  def broadcast_read_state_badges(root_entry)
    user_ids = root_entry.all_comments.select(:user_id).distinct.pluck(:user_id)
    user_ids << root_entry.user_id

    User.where(id: user_ids.uniq).find_each do |user|
      user.broadcast_read_state_update!(root_entry)
      user.broadcast_notifications_badge_update!
    end
  end

  def broadcast_comments_counter(root_entry)
    Turbo::StreamsChannel.broadcast_replace_to(
      :entries,
      target: [ root_entry, :comments_counter ],
      renderable: Components::Entries::CommentsCounter.new(entry: root_entry),
      layout: false
    )
  end
end
