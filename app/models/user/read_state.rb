module User::ReadState
  extend ActiveSupport::Concern

  def mark_entry_as_read!(entry)
    root_entry = entry.root || entry
    now = Time.current

    state = entry_reads.find_or_initialize_by(entry: root_entry)
    state.read_at ||= now
    state.save! if state.changed?

    broadcast_read_state_update!(root_entry)
  end

  def entry_read_state_for(entry)
    # root_entry = entry.root || entry
    # entry_reads.find_by(entry: root_entry)
    entry_reads.detect { |read| read.entry_id == (entry.root_id || entry.id) }
  end

  def post_read_for?(entry)
    entry_read_state_for(entry)&.read_at.present?
  end

  def broadcast_read_state_update!(entry)
    # Используем root_entry, если прочтение по дереву
    root_entry = entry.root || entry

    broadcast_replace_to(
      [ :user, id ], # Стрим в личный канал пользователя
      target: [ root_entry, :read_badge ],
      renderable: Components::Entries::ReadBadge.new(entry: root_entry, user: self),
      layout: false
    )
  end
end
