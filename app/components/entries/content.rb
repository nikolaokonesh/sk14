# frozen_string_literal: true

class Components::Entries::Content < Phlex::HTML
  def initialize(entry:)
    @entry = entry
  end

  def view_template
    plain raw @entry.content.to_s
  end
end
