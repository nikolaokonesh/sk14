# frozen_string_literal: true

class Components::Entries::TagsListing < Components::Base
  def initialize(entry:)
    @entry = entry
  end

  def view_template
    # Получаем объект entryable (Post)
    post = @entry.entryable

    # Собираем только активные теги
    active_tags = Post::TAG_CONFIG.select { |key, _| post.send(key) }
    return if active_tags.empty?

    div(class: "flex flex-wrap gap-1") do
      active_tags.each do |key, data|
        span(
          class: [
            "font-bold uppercase rounded text-[9px] px-1",
            data[:color]
          ]
        ) { data[:label] }
      end
    end
  end
end
