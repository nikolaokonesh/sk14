# frozen_string_literal: true

class Views::Users::Name::Edit < Views::Base
  def initialize(user:)
    @user = user
  end

  def page_title = "Как Вас зовут?"
  def layout = Layout

  def view_template
    div(
      class:
        "hero bg-no-repeat bg-center bg-cover bg-base-200/70 bg-blend-soft-light rounded",
      style: %(background-image: url('#{asset_path("bg_auth.png")}'))
    ) do
      div(class: "hero-content flex-col lg:flex-row-reverse") do
        div(class: "text-center lg:text-left") do
          h1(class: "text-5xl font-bold") { page_title }
          p(class: "py-6") do
            span { "Введите свою фамилию и имя," }
            span(class: "block") { "можно добавить отчество." }
            span(class: "block") { "Вы можете пропутить это действие." }
          end
        end
        div(class: "card bg-base-300 w-full max-w-sm shrink-0 shadow-2xl") do
          div(class: "card-body") do
            fieldset(class: "fieldset") do
              form_with(model: @user, url: user_name_path(@user), method: :put) do |f|
                render_form_field(f, :name, "Как Вас зовут?") do
                  f.text_field :name, maxlength: 50, placeholder: "Иванов Иван",
                    class:  [ "input", { "input-error": @user.errors[:name].any? } ]
                end
                plain f.submit "Сохранить", class: "btn btn-outline mt-4"
              end
            end
          end
        end
      end
    end
  end

  private

  def render_form_field(form, field, label, &block)
    div do
      form.label field, label, class: "block text-sm font-medium text-gray-700 mb-1"
      yield
      if @user.errors[field].any?
        p(class: "text-red-500 text-sm mt-1") { @user.errors[field].join(", ") }
      end
    end
  end
end
