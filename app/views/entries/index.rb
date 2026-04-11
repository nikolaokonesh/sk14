# frozen_string_literal: true

class Views::Entries::Index < Views::Base
  def initialize(entries:)
    @entries = entries
  end

  def view_template
    @entries.each do |entry|
      div(class: "block  mb-3") do
        cache(entry) do
          a(href: entry_path(entry), class: "block hover:opacity-70 duration-200") do
            plain truncate entry.content.to_plain_text, length: 100
          end
        end
        render Shared::CreatedAt.new(entry: entry)
      end
    end
  end
end
