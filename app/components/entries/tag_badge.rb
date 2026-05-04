# frozen_string_literal: true

class Components::Entries::TagBadge < Components::Base
  def initialize(entry:)
    @entry = entry
  end

  def view_template
    active_tags = Post::TAG_CONFIG.select { |key, _| @entry.send(key) }

    div(class: "flex flex-wrap gap-1") do
      return if active_tags.empty?
      active_tags.each do |key, data|
        span(
          class: [
            "font-bold uppercase tracking-widest rounded text-[9px] px-1",
            data[:color_bg],
            data[:color_text]
          ]
        ) { data[:label] }
      end
    end
  end
end
