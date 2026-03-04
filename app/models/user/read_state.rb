module User::ReadState
  extend ActiveSupport::Concern

  def mark_entry_as_read!(entry)
    root_entry = entry.root || entry
    now = Time.current

    state = entry_read_states.find_or_initialize_by(entry: root_entry)
    state.post_read_at ||= now
    state.comments_read_at = now
    state.save! if state.changed?

    notifications.where(read_at: nil).includes(:event).find_each do |notification|
      params = notification.event&.params || {}
      root_entry_id = params["root_entry_id"] || params[:root_entry_id]
      next unless root_entry_id.to_i == root_entry.id

      notification.update_columns(read_at: now, updated_at: now)
    end

    broadcast_read_state_update!(root_entry)
  end

  def entry_read_state_for(entry)
    root_entry = entry.root || entry
    entry_read_states.find_by(entry: root_entry)
  end

  def post_read_for?(entry)
    entry_read_state_for(entry)&.post_read_at.present?
  end

  def unread_comments_count_for(entry)
    root_entry = entry.root || entry
    state = entry_read_state_for(root_entry)
    from_time = state&.comments_read_at || root_entry.created_at

    root_entry.all_comments.where("created_at > ?", from_time).where.not(user_id: id).count
  end

  def unread_notifications_count
    notifications.where(read_at: nil).count
  end

  def show_unread_comments_count_for?(entry)
    root_entry = entry.root || entry
    return true if root_entry.user_id == id

    entries.where(entryable_type: "Comment", root_id: root_entry.id).exists?
  end

  def broadcast_notifications_badge_update!
    broadcast_update_to(
      [ :user, id ],
      target: [ self, :notifications_badge ],
      renderable: Components::Menu::NotificationsBadge.new(user: self),
      layout: false
    )
  end

  def broadcast_read_state_update!(entry)
    broadcast_replace_to(
      [ :user, id ],
      target: [ entry, :read_state_badge ],
      renderable: Components::Entries::ReadStateBadge.new(entry: entry, user: self),
      layout: false
    )
  end
end
