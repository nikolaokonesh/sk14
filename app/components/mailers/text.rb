class Components::Mailers::Text < Phlex::HTML
  def view_template
    plain "Sk14.Ru"
    plain "\n\n"
    yield
    plain "\n\n\n"
    plain "С Уважением,"
    plain "\n"
    plain "Компания Sk14.Ru"
  end
end
