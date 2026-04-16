# frozen_string_literal: true

class Views::Entries::Index < Views::Base
  def initialize(entries:)
    @entries = entries
  end

  def view_template
    turbo_stream_from "entries"

    @entries.each do |entry|
      div(class: "block mb-3") do
        span(class: "mr-2") { entry.user.username }
        span(class: "text-xs") { render Components::Shared::CreatedAt.new(entry: entry) }
        cache(entry) do
          a(href: entry_path(entry), class: "block hover:opacity-70 duration-200") do
            plain truncate strip_tags(entry.content.to_s).strip, length: 100
          end
        end
      end
      div(class: "divider")
    end
  end
end
