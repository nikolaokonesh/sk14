class Comments::Streams::DestroyJob < ApplicationJob
  queue_as :default

  def perform(root_id:, entry_id:)
    root_entry = Entry.find_by(id: root_id)
    return unless root_entry

    Turbo::StreamsChannel.broadcast_remove_to([ root_entry, :comments ], target: "entry_#{entry_id}")

    broadcast_read_state_badges(root_entry)
    broadcast_comments_counter(root_entry)
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
