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
          @entries.each_with_index do |entry, i|
            prev_by_time = @entries[i + 1]
            next_by_time = i > 0 ? @entries[i - 1] : nil

            is_first = prev_by_time.nil? || prev_by_time.user_id != entry.user_id
            is_last = next_by_time.nil? || next_by_time.user_id != entry.user_id
            render Components::Entries::Card.new(entry: entry, is_first: is_first, is_last: is_last)
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
