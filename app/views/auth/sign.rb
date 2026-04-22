# frozen_string_literal: true

class Views::Auth::Sign < Views::Auth
  def initialize(params:, session:)
    @params = params
    @session = session
  end

  def view_template
    # На мобильных items-stretch, на десктопе центрируем по вертикали
    div(class: "min-h-screen flex items-stretch md:items-center justify-center bg-base-100") do
      main(class: "relative w-full max-w-6xl mx-auto md:p-4") do
        render Components::Shared::BgGradient.new(opacity: "opacity-100")

        div(
          class: "hero min-h-screen md:min-h-[600px] md:rounded-3xl overflow-hidden shadow-2xl relative flex flex-col"
        ) do
          # Затемняющий слой для глубины
          div(class: "absolute inset-0 bg-neutral/60 backdrop-blur-[3px]")

          # Контейнер контента: копия структуры страницы верификации
          div(class: "hero-content relative z-10 flex-col lg:flex-row lg:items-start lg:justify-between gap-10 p-6 md:p-16 w-full") do
            # ЛЕВАЯ ЧАСТЬ: Приветствие
            div(class: "text-center lg:text-left text-neutral-content max-w-md lg:mt-10") do
              div(class: "mb-6 inline-flex p-3 bg-white/10 rounded-2xl backdrop-blur-md shadow-inner") do
                plain raw lucide_icon("log-in", class: "size-10 text-primary")
              end

              h1(class: "text-4xl md:text-6xl font-black tracking-tighter leading-[0.9] mb-8") do
                plain "Добро"
                br(class: "hidden lg:block")
                span(class: "text-primary lg:block") { " пожаловать" }
              end

              p(class: "text-lg md:text-xl opacity-90 font-medium leading-relaxed mb-6") do
                "Без паролей и лишней суеты. Просто введите Email, и мы пришлем магический ключ."
              end

              p(class: "text-sm opacity-60 hidden lg:block italic mt-10") do
                "Мы заботимся о безопасности: код подтверждения действует только 10 минут."
              end
            end

            # ПРАВАЯ ЧАСТЬ: Карточка входа
            div(class: "card bg-base-100 shadow-2xl border border-white/10 w-full max-w-sm sm:rounded-3xl lg:mt-4") do
              div(class: "card-body p-6 md:p-8") do
                h2(class: "card-title text-xl md:text-2xl font-bold mb-1") { "Вход в аккаунт" }
                p(class: "text-[10px] md:text-xs opacity-50 uppercase tracking-widest font-semibold") do
                  "Авторизация по Email"
                end

                form_with(url: auth_sign_path, class: "space-y-6") do |f|
                  div(class: "form-control") do
                    plain f.email_field :email,
                                        value: @params,
                                        inputmode: "email",
                                        placeholder: "example@mail.ru",
                                        required: true,
                                        class: "input input-bordered input-lg w-full focus:input-primary transition-all shadow-inner text-base"
                  end

                  div(class: "form-control mt-4") do
                    plain f.submit "Получить код",
                                  class: "btn btn-primary btn-lg w-full shadow-lg shadow-primary/30 text-base md:text-lg",
                                  data: { turbo_submits_with: "..." }
                  end
                end

                # Блок уведомления (если сессия уже есть)
                if @session.present?
                  div(class: "mt-8 p-4 rounded-2xl bg-info/10 border border-info/20 text-sm animate-pulse") do
                    div(class: "flex items-center gap-2 mb-2") do
                      plain raw lucide_icon("info", class: "size-4 text-info")
                      p(class: "font-bold") { "Код уже отправлен" }
                    end
                    a(href: auth_verification_path, class: "btn btn-link btn-sm btn-primary p-0 h-auto min-h-0 normal-case") do
                      "Перейти к подтверждению →"
                    end
                  end
                end

                # Футер карточки
                div(class: "mt-8 pt-6 border-t border-base-content/5 text-center") do
                  p(class: "text-[10px] opacity-40 uppercase tracking-tight") do
                    "Заходя, вы принимаете условия сервиса"
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
