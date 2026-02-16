# frozen_string_literal: true

class Views::Entries::Index < Views::Base
  def initialize(entries:, pagy:, params:, query:)
    @entries = entries
    @pagy = pagy
    @params = params
    @query = query
  end

  def page_title = "Лента"
  def layout = Layout

  def view_template
    if authenticated?
      turbo_stream_from :entries
    end
    render Components::Menu::Search.new(query: @query)
    turbo_frame_tag :entries_list, target: "_top" do
      div(class: "w-full") do
        render Components::Entries::List.new(entries: @entries, pagy: @pagy, params: @params)
      end
    end
  end
end
