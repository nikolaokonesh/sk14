# frozen_string_literal: true

class Views::Auth::Verification < Views::Base
  def initialize(session:)
    @session = session
  end

  def page_title = "Введите код"
  def layout = Layout

  def view_template
    div(class: "flex flex-col h-screen") do
      main(class: "w-full md:w-3xl xl:w-4xl mx-auto md:px-0 flex flex-grow") do
        div(
          class:
            "hero bg-no-repeat bg-center bg-cover bg-base-200/70 bg-blend-soft-light rounded",
          style: %(background-image: url('#{asset_path("bg_auth.png")}'))
        ) do
          div(class: "hero-content flex-col lg:flex-row-reverse lg:items-center") do
            div(class: "text-center lg:text-left") do
              h1(class: "text-3xl md:text-4xl font-bold") { "Проверьте свою электронную почту" }
              p(class: "py-6") do
                plain " Введите проверочный код отправленный на ваш адрес электронной почты "
                span(class: "font-bold") { @session }
              end
            end
            div(class: "card bg-base-300 w-full max-w-sm shrink-0 shadow-2xl") do
              div(class: "card-body") do
                fieldset(class: "fieldset") do
                  form_with(url: auth_verification_path) do |f|
                    plain f.hidden_field :email, value: @session
                    label(class: "label mb-2") { "Введите код" }
                    plain f.number_field :verification_code,
                                      placeholder: "Проверочный код",
                                      min: 000000,
                                      max: 999999,
                                      step: 1,
                                      oninput: "this.value = this.value.slice(0, 6)",
                                      required: true,
                                      class: "input input-xl md:input-lg"
                    plain f.submit "Подтвердить", class: "btn btn-outline mt-4", data: { turbo_submits_with: "Проверяем..." }
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
