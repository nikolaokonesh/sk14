# frozen_string_literal: true

class Components::Pagination::ScrollableList < Phlex::HTML
  include Phlex::Rails::Helpers::TurboFrameTag

  def initialize(pagy:, entries:)
    @pagy = pagy
    @entries = entries
  end

  def view_template
    ordered_entries = @entries.to_a.reverse

    turbo_frame_tag "load_prev_entries_page-#{@pagy.page}", refresh: :morph do
      div(class: "w-full mt-3") do
        render Components::Pagination::NextPage.new(pagy: @pagy, frame_prefix: "load_prev_entries_page") if @pagy.next.present?

        div(id: "entries_#{@pagy.page}", class: "grid grid-cols-1 gap-3 px-2") do
          entry_groups = ordered_entries.chunk { |entry| entry.user_id }.to_a

          entry_groups.each do |_user_id, group|
            render_group(group)
          end
        end
      end
    end
  end

  private

  def render_group(group)
    render Components::Entries::Group.new(user: group.first.user) do
      group.each_with_index do |entry, i|
        render Components::Entries::Card.new(
          entry: entry,
          is_first: (i == 0),
          is_last: (i == group.size - 1),
          show_avatar: false
        )
      end
    end
  end
end
