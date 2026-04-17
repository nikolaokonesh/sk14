# frozen_string_literal: true

class Views::Entries::Index < Views::Base
  def initialize(entries:)
    @entries = entries
  end

  def view_template
    turbo_stream_from(:entries)

    render Components::Entries::IndexCardTop.new

    ul(class: "list bg-base-100 rounded-box shadow-md") do
      @entries.each do |entry|
        render Components::Entries::Card.new(entry: entry)
      end
    end
  end
end
