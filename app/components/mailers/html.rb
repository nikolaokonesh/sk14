class Components::Mailers::Html < Phlex::HTML
  def view_template
    doctype
    html do
      head do
        meta charset: "utf-8"
        style do
          plain <<~CSS
            body {
              font-family: Arial, sans-serif;
            }
            .highlight {
              background-color: yellow;
            }
            .signature {
              font-style: italic;
            }
          CSS
        end
      end
      body do
        div do
          b { "Sk14.Ru" }
        end
        yield
        div { "С Уважением," }
        div { "Компания Sk14.Ru" }
      end
    end
  end
end
