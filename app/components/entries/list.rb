# frozen_string_literal: true

class Components::Entries::List < Phlex::HTML
  include Phlex::Rails::Helpers::TurboFrameTag
  def initialize(entries:, pagy:, params:)
    @entries = entries
    @pagy = pagy
    @params = params
  end

  def view_template
    div(class: "w-full") do
      div(id: "entries", class: "grid grid-cols-1 gap-3 px-2") do
        if @entries.any?
          @entries.each do |entry|
            render Components::Entries::Card.new(entry: entry)
          end
        else
          p(class: "text-center my-10") { "Нет никаких объявлений..." }
        end
      end
    end
    render Components::Pagination::NextPage.new(pagy: @pagy) if @pagy.next.present?
    render Components::Pagination::ScrollableList.new(entries: @entries, pagy: @pagy) if @params
  end
end
