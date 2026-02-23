# frozen_string_literal: true

class Components::Entries::List < Phlex::HTML
  include Phlex::Rails::Helpers::TurboFrameTag

  def initialize(entries:, pagy:, params:)
    @entries = entries
    @pagy = pagy
    @params = params
  end

  def view_template
    ordered_entries = @entries.to_a.reverse

    div(class: "w-full") do
      render Components::Pagination::NextPage.new(pagy: @pagy, frame_prefix: "load_prev_entries_page") if @pagy.next.present?

      div(id: "entries", class: "grid grid-cols-1 gap-3 px-2") do
        if ordered_entries.any?
          entry_groups = ordered_entries.chunk { |entry| entry.user_id }.to_a

          entry_groups.each_with_index do |(user_id, group), index|
            # Проверка на группу для начальной загрузки
            is_last_group = (index == entry_groups.size - 1) && !@has_next
            render_group(user_id, group, is_last_group)
          end
        else
          p(class: "text-center my-10") { "Нет никаких объявлений..." }
        end
      end
    end

    render Components::Pagination::ScrollableList.new(entries: @entries, pagy: @pagy) if @params
  end

  private

  def render_group(user_id, group, is_last_group)
    anchor = group.first
    group_wrapper_id = "group_entry_#{anchor.id}"
    bubbles_id = is_last_group ? "group_bubbles_entry_#{anchor.group_anchor_id}" : nil

    render Components::Entries::Group.new(user: group.first.user, group_wrapper_id: group_wrapper_id, bubbles_id: bubbles_id) do
      group.each_with_index do |entry, i|
        is_first = (i == 0)
        is_last = (i == group.size - 1)
        is_the_very_last = is_last_group && is_last
        is_target = (entry.id == @highlight_id)
        is_the_very_last_classes = is_the_very_last ? "last-entry" : ""
        target_classes = is_target ? "js-highlighted-entry" : ""
        render Components::Entries::Card.new(
          entry: entry,
          is_first: is_first,
          is_last: is_last,
          show_avatar: false,
          class_target: "#{target_classes} #{is_the_very_last_classes}"
        )
      end
    end
  end
end
