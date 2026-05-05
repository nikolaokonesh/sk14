class Components::Entries::ReadBadge < Components::Base
  def initialize(entry:, read_entry_ids: nil, user: nil)
    @entry = entry
    @read_entry_ids = read_entry_ids
    @user = user
  end

  def view_template
    is_read = if @read_entry_ids
                @read_entry_ids.include?(@entry.id)
    elsif @user
                @user.post_read_for?(@entry)
    else
                false
    end

    # ДОБАВЬТЕ ID СЮДА:
    span(id: dom_id(@entry, :read_badge), class: [ is_read ? "text-info" : "text-gray-500 opacity-30" ]) do
      lucide_icon("check-check", size: 18)
    end
  end
end
