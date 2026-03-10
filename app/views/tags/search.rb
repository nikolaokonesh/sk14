# frozen_string_literal: true

class Views::Tags::Search < Components::Base
  def initialize(
    categories:,
    counts:,
    query:,
    all_posts_count:
  )
    @categories = categories
    @counts = counts
    @query = query
    @all_posts_count = all_posts_count
  end

  def view_template
    turbo_frame_tag "popular_tags", refresh: :morph do
      div(class: "flex gap-2 overflow-x-auto px-4 pb-2 no_scrollbar flex-nowrap bg-base-300") do
        render_tag_link("Все", nil, @all_posts_count)

        @categories.each do |category|
          count = @counts[category.downcase] || 0
          render_tag_link(category.capitalize, category, count)
        end
      end
    end
  end

  private

    def render_tag_link(label, value, count)
      is_active = (@query == value) || (value.nil? && @query.blank?)
      active_class = is_active ? "btn-primary" : "btn-ghost bg-base-200"

      a(
        href: root_path(query: value),
        class: "btn btn-sm rounded-full whitespace-nowrap #{active_class}",
        data: {
          turbo_frame: "entries_list",
          turbo_prefetch: "false",
          search_target: "tag",
          action: "click->search#set_query",
          search_value: value || ""
        }
      ) do
        plain label
        span(class: "opacity-60 text-xs ml-1") { "(#{count})" }
      end
    end
end
