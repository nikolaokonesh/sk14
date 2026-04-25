# frozen_string_literal: true

class Components::Shared::BgGradient < Components::Base
  def initialize(opacity: "opacity-20", inset: "inset-0.5")
    @opacity = opacity
    @inset = inset
  end

  def view_template
    div(
      class: [
        "absolute blur-2xl rounded-[3rem]",
        @opacity,
        @inset,
        "bg-gradient-to-br from-error via-secondary via-success via-primary to-blue-600"
      ]
    )
  end
end
