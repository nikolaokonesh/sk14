# frozen_string_literal: true

class Views::Tags::Index < Views::Base
  def initialize(tags:)
    @tags = tags
  end

  def page_title = "🔖Все теги"
  def layout = Layout

  def view_template
    if authenticated?
      turbo_stream_from :tags
    end
    div(class: "w-full") do
      div(class: "mx-4 tag-cloud grid grid-cols-2 md:grid-cols-4 lg:grid-cols-6 gap-3") do
        @tags.each do |tag|
          size = case tag.usage_count
          when 0..1 then "text-sm opacity-60"
          when 2..7 then "text-base opacity-75"
          when 8..15 then "text-lg opacity-90"
          else           "text-2xl font-bold opacity-100"
          end

          div do
            a(href: tag_path(tag.id), class: "tag-item #{size} hover:underline hover:text-blue-600 transition") do
              plain tag.name
              plain span(class: "text-xs opacity-70") { " × #{tag.usage_count}" }
            end
          end
        end
      end

      if @tags.empty?
        p(class: "text-gray-500") { "Пока нет тегов. Создайте первое объявление!" }
      end
    end
  end
end
