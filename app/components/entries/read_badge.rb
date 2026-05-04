class Components::Entries::ReadBadge < Components::Base
  def initialize(entry:, read_entry_ids:)
    @entry = entry
    @read_entry_ids = read_entry_ids
  end

  def view_template
    # Мгновенная проверка в памяти
    is_read = @read_entry_ids.include?(@entry.id)

    span(class: [ is_read ? "text-info" : "text-gray-500 opacity-30" ]) do
      lucide_icon("check-check", size: 18)
    end
  end
end
