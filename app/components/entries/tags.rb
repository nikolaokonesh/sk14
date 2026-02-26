# frozen_string_literal: true

class Components::Entries::Tags < Components::Base
  def initialize(
    entry:
  )
    @entry = entry
  end

  def view_template
    div(class: "flex flex-wrap gap-2") do
      @entry.tags.each do |tag|
        a(href: tag_path(tag.id), class: "text-xs badge px-1") { tag.name }
      end
    end
  end
end
