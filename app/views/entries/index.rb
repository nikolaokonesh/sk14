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

    div(class: "flex flex-col h-screen overflow-hidden") do
      div(class: "flex flex-col") do
        div(class: "flex items-center bg-base-300 z-100") { render Components::Menu::Header.new(query: @query, categories: @categories, counts: @counts) }
      end

      render Components::Style::BlurBackground.new
      div(class: "flex-1 overflow-y-auto no-scrollbar relative", data: { controller: "autoscroll infinite-scroll" }) do
        turbo_frame_tag :entries_list, target: "_top", refresh: :morph do
          div(class: "w-full min-h-full") do
            render Components::Entries::List.new(entries: @entries, pagy: @pagy, params: @params)
            render Components::Entries::ButtonNewBadge.new
            div(class: "snap-end") { }
          end
        end
      end

      div(class: "flex items-center bg-base-300 z-100") { render Components::Menu::Bottom.new }
    end
  end
end
