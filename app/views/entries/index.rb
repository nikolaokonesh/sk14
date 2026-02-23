# frozen_string_literal: true

class Views::Entries::Index < Views::Base
  def initialize(entries:, pagy:, params:, query:, categories:, counts:)
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
    end

    render Components::Menu::Search.new(query: @query, categories: @categories, counts: @counts)

    turbo_frame_tag :entries_list, target: "_top" do
      div(class: "w-full") do
        div(class: "h-[69svh] overflow-y-auto overflow-x-visible no-scrollbar", data: { controller: "autoscroll infinite-scroll" }) do
          render Components::Entries::List.new(entries: @entries, pagy: @pagy, params: @params)
        end
      end
    end
  end
end
