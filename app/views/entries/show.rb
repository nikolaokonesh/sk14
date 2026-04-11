# frozen_string_literal: true

class Views::Entries::Show < Views::Base
  def initialize(entry:)
    @entry = entry
  end

  def view_template
    div(class: "lexxy-show") do
      plain raw @entry.content.to_s
    end
  end
end
