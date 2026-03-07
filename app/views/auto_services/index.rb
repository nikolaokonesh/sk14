# frozen_string_literal: true

class Views::AutoServices::Index < Views::Base
  def initialize(entries:, pagy:, params:, mode:)
    @entries = entries
    @pagy = pagy
    @params = params
    @mode = mode
  end

  def page_title = "Услуги авто"
  def layout = Layout

  def view_template
    turbo_stream_from :auto_services

    div(class: "flex flex-col h-screen overflow-hidden") do
      div(class: "flex flex-col") do
        div(class: "flex items-center bg-base-300 z-100") do
          render Components::AutoServices::Header.new(mode: @mode)
        end
      end

      render Components::Style::BlurBackground.new
      div(class: "flex-1 overflow-y-auto no-scrollbar relative mt-2", data: { controller: "autoscroll infinite-scroll" }) do
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
