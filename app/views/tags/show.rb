# frozen_string_literal: true

class Views::Tags::Show < Views::Base
  def initialize(
    entries:,
    tag:,
    pagy:,
    params:
  )
    @entries = entries
    @tag = tag
    @pagy = pagy
    @params = params
  end

  def page_title = @tag.name
  def layout = Layout

  def view_template
    if authenticated?
      turbo_stream_from :tag, @tag.id
    end

    div do
      div(class: "p-4 mb-4") do
        if authenticated?
          render Components::Subscriptions::Button.new(user: Current.user, followable: @tag)
        end
      end

      if @entries.any?
        div(class: "space-y-6") do
          render Components::Entries::List.new(entries: @entries, pagy: @pagy, params: @params)
        end
      else
        div(class: "text-center py-10 text-gray-500") do
          p { "Нет объявлений с тегом #{page_title}" }
        end
      end
    end
  end
end
