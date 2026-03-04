class Components::Style::BlurBackground < Phlex::HTML
  def view_template
    div(class: "relative h-10 -mb-10 backdrop-blur-xs z-10 border-t border-base-300",
        style: "mask-image: linear-gradient(to bottom, black 40%, transparent 100%);
                -webkit-mask-image: linear-gradient(to bottom, black 40%, transparent 100%)") { }
  end
end
