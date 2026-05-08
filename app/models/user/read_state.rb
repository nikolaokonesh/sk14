# app/models/concerns/user/read_state.rb
module User::ReadState
  extend ActiveSupport::Concern

  # Получаем Set ID-шников из Solid Cache
  def read_entry_ids
    @read_entry_ids ||= Rails.cache.fetch("user/#{id}/read_ids") { [] }.to_set
  end

  def mark_entry_as_read!(entry)
    target_id = entry.root_id || entry.id
    ids_array = Rails.cache.read("user/#{id}/read_ids") || []

    unless ids_array.include?(target_id)
      ids_array.unshift(target_id)
      ids_array = ids_array.take(500) # Лимит, чтобы кэш не пух

      Rails.cache.write("user/#{id}/read_ids", ids_array)
      @read_entry_ids = ids_array.to_set # Сброс мемоизации

      # Сразу шлем обновление в браузер
      broadcast_read_state_update!(entry)
    end
  end

  def post_read_for?(entry)
    read_entry_ids.include?(entry.root_id || entry.id)
  end

  def broadcast_read_state_update!(entry)
    root_entry = entry.root || entry

    broadcast_replace_to(
      self, # Шлем в канал юзера (совпадает с turbo_stream_from(current_user))
      target: ActionView::RecordIdentifier.dom_id(root_entry, :read_badge),
      renderable: Components::Entries::ReadBadge.new(entry: root_entry, read_entry_ids: read_entry_ids),
      layout: false
    )
  end
end
