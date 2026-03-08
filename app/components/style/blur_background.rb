class Components::Style::BlurBackground < Phlex::HTML
  def view_template
    div(class: "relative h-10 -mb-10 w-full bg-gradient-to-b z-10 from-base-300 to-transparent") do
      div(class: "relative h-10 -mb-10 backdrop-blur-xs border-t border-base-300",
          style: "mask-image: linear-gradient(to bottom, black 40%, transparent 100%);
                  -webkit-mask-image: linear-gradient(to bottom, black 40%, transparent 100%)") { }
    end
  end
end
