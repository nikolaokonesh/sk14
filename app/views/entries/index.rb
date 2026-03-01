# frozen_string_literal: true

class Views::Entries::Index < Views::Base
  def initialize(
    entries:,
    pagy:,
    params:,
    query:,
    categories:,
    counts:
  )
    @entries = entries
    @pagy = pagy
    @params = params
    @query = query
    @categories = categories
    @counts = counts
  end

  def page_title = "Лента"
  def layout = Layout

  def view_template
    if authenticated?
      turbo_stream_from :entries
      if @query.present?
        turbo_stream_from :entries_tags_query
      end
    end

    render Components::Menu::Search.new(query: @query, categories: @categories, counts: @counts)


    turbo_frame_tag :entries_list, target: "_top", refresh: :morph do
      div(class: "w-full snap-start") do
        div(class: "relative h-15 -mb-15 bg-gradient-to-b from-base-100 to-transparent z-10 pointer-events-none") { }
        div(class: "h-[66svh] overflow-y-auto overflow-x-visible no-scrollbar", data: { controller: "autoscroll infinite-scroll" }) do
          render Components::Entries::List.new(entries: @entries, pagy: @pagy, params: @params)
          render Components::Entries::ButtonNewBadge.new
          div(class: "snap-end") { }
        end
      end
    end
  end
end
