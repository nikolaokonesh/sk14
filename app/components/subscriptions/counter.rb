# frozen_string_literal: true

class Components::Subscriptions::Counter < Components::Base
  def initialize(followable:)
    @followable = followable
  end

  def view_template
    span(id: dom_id(@followable, :followers_count), class: "inline-flex items-center rounded-full bg-gray-100 px-2.5 py-0.5 text-xs font-medium text-gray-800") do
      plain "Подписчиков: #{@followable.followers_count}"
    end
  end
end
