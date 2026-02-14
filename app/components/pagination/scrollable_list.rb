# frozen_string_literal: true

class Components::Pagination::ScrollableList < Phlex::HTML
  include Phlex::Rails::Helpers::TurboFrameTag

  def initialize(pagy:, entries:)
    @pagy = pagy
    @entries = entries
  end

  def view_template
    turbo_frame_tag "entries-page-#{@pagy.page}", refresh: :morph do
      div(class: "w-full mt-3") do
        div(id: "entries_#{@pagy.page}", class: "grid grid-cols-1 gap-3 px-2") do
          @entries.each do |entry|
            render Components::Entries::Card.new(entry: entry)
          end
        end
      end
      render Components::Pagination::NextPage.new(pagy: @pagy) if @pagy.next.present?
    end
  end
end
