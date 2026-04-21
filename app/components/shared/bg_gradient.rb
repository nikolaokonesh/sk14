# frozen_string_literal: true

class Components::Shared::BgGradient < Components::Base
  def initialize(opacity: "opacity-20")
    @opacity = opacity
  end

  def view_template
    div(
      class: [
        "absolute -inset-2 blur-2xl rounded-[3rem]",
        @opacity,
        "bg-gradient-to-br from-error via-success via-warinig to-info"
      ]
    )
  end
end
