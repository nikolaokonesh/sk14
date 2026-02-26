# frozen_string_literal: true

class Views::Auth::Sign < Views::Base
  def initialize(
    params:,
    session:
  )
    @params = params
    @session = session
  end

  def page_title = "Войти"
  def layout = Layout

  def view_template
    div(class: "flex flex-col h-screen") do
      main(class: "w-full md:w-3xl xl:w-4xl mx-auto md:px-0 flex flex-grow") do
        div(
          class:
            "hero bg-no-repeat bg-center bg-cover bg-base-200/70 bg-blend-soft-light rounded",
          style: %(background-image: url('#{asset_path("bg_auth.png")}'))
        ) do
          div(class: "hero-content flex-col lg:flex-row-reverse") do
            div(class: "text-center lg:text-left") do
              h1(class: "text-5xl font-bold") { "Давайте начнём!" }
              p(class: "py-6") do
                " Мы отправим код подтверждения на Ваш адрес Email."
              end
            end
            div(class: "card bg-base-300 w-full max-w-sm shrink-0 shadow-2xl") do
              div(class: "card-body") do
                fieldset(class: "fieldset") do
                  form_with(url: auth_path) do |f|
                    plain f.email_field :email,
                                        value: @params,
                                        placeholder: "Введите Email адрес",
                                        required: true,
                                        class: "input input-xl md:input-lg"
                    plain f.submit "Отправить код", class: "btn btn-outline mt-4", data: { turbo_submits_with: "Ждите..." }
                  end
                  div(class: "mt-4 ml-2") do
                    if @session.present?
                      plain @session
                      a(href: auth_verification_path, class: "link link-hover mx-2 font-bold") { "подтвердите код" }
                      plain p { "или введите Email ещё раз чтобы получить новый код." }
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
end
