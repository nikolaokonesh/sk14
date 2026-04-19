# frozen_string_literal: true

class Views::Entries::Index < Views::Base
  def initialize(entries:)
    @entries = entries
  end

  def view_template
    turbo_stream_from(:entries)

    user = current_user

    render Components::Entries::IndexCardTop.new

    ul(id: "entries_list", class: "list bg-base-100 rounded-box shadow-md") do
      @entries.each do |entry|
        render Components::Entries::Card.new(entry: entry, user: user)
      end
    end
  end
end
