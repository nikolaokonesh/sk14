# frozen_string_literal: true

module User::ReadState
  extend ActiveSupport::Concern

  READ_HISTORY_LIMIT = 150

  def read_entry_ids
    @read_entry_ids ||= cached_read_entry_ids.to_set
  end

  def mark_entry_as_read!(entry)
    target_id = read_target_id(entry)
    ids_array = Rails.cache.read(read_ids_cache_key) || []

    return if ids_array.include?(target_id)

    ids_array.unshift(target_id)
    ids_array = ids_array.take(READ_HISTORY_LIMIT)

    Rails.cache.write(read_ids_cache_key, ids_array)
    @read_entry_ids = ids_array.to_set

    broadcast_read_state_update!(entry)
  end

  def post_read_for?(entry)
    read_entry_ids.include?(read_target_id(entry))
  end

  def broadcast_read_state_update!(entry)
    root_entry = entry.root || entry

    broadcast_replace_to(
      self,
      target: ActionView::RecordIdentifier.dom_id(root_entry, :read_badge),
      renderable: Components::Entries::ReadBadge.new(entry: root_entry, read_entry_ids: read_entry_ids),
      layout: false
    )
  end

  private

  def cached_read_entry_ids
    Rails.cache.fetch(read_ids_cache_key) { [] }
  end

  def read_ids_cache_key
    "user/#{id}/read_ids"
  end

  def read_target_id(entry)
    entry.root_id || entry.id
  end
end
