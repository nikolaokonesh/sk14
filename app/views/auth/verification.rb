# frozen_string_literal: true

class Views::Auth::Verification < Views::Auth
  def initialize(session:)
    @session = session
  end

  def page_title = "Подтверждение входа"

  def view_template
    # На мобильных items-stretch, на десктопе центрируем по вертикали
    div(class: "min-h-screen flex items-stretch md:items-center justify-center bg-base-100") do
      main(class: "w-full max-w-6xl mx-auto md:p-4") do
        
        div(
          class: "hero min-h-screen md:min-h-[600px] md:rounded-3xl overflow-hidden shadow-2xl bg-no-repeat bg-center bg-cover relative flex flex-col",
          style: %(background-image: url('#{asset_path("bg_auth.png")}'))
        ) do
          # Слой размытия и глубины
          div(class: "absolute inset-0 bg-neutral/60 backdrop-blur-[3px]")

          # Контейнер контента: lg:items-start выравнивает верх текста и формы на одной линии
          div(class: "hero-content relative z-10 flex-col lg:flex-row lg:items-start lg:justify-between gap-10 p-6 md:p-16 w-full") do
            
            # ЛЕВАЯ ЧАСТЬ: Инструкция (выровнена по левому краю на десктопе)
            div(class: "text-center lg:text-left text-neutral-content max-w-md lg:mt-10") do
              div(class: "mb-6 inline-flex p-3 bg-white/10 rounded-2xl backdrop-blur-md shadow-inner") do
                plain raw lucide_icon("mail-check", class: "size-10 text-primary")
              end
              
              h1(class: "text-4xl md:text-6xl font-black tracking-tighter leading-[0.9] mb-8") do
                plain "Почти"
                br(class: "hidden lg:block")
                span(class: "text-primary lg:block") { " готово!" }
              end
              
              p(class: "text-lg md:text-xl opacity-90 font-medium leading-relaxed mb-4") do
                plain "Код уже на почте:"
              end
              
              # Выделенный адрес почты
              div(class: "inline-block px-4 py-2 bg-primary/20 border border-primary/30 rounded-xl backdrop-blur-sm shadow-lg") do
                span(class: "text-white font-mono text-sm md:text-base") { @session }
              end

              p(class: "mt-10 text-sm opacity-60 hidden lg:block italic") do
                "Проверьте папку «Спам», если письмо не пришло в течение минуты."
              end
            end

            # ПРАВАЯ ЧАСТЬ: Карточка с вводом
            div(class: "card bg-base-100 shadow-2xl border border-white/10 w-full max-w-sm sm:rounded-3xl lg:mt-4") do
              div(class: "card-body p-6 md:p-8") do
                h2(class: "card-title text-xl md:text-2xl font-bold mb-1") { "Введите код" }
                p(class: "text-[10px] md:text-xs opacity-50 mb-8 uppercase tracking-widest font-semibold") do 
                  "6 цифр верификации" 
                end

                form_with(url: auth_verification_path, class: "space-y-6") do |f|
                  plain f.hidden_field :email, value: @session
                  
                  div(class: "form-control") do
                    # Поле оптимизировано для быстрого ввода (OTP)
                    plain f.number_field :verification_code,
                                      placeholder: "······",
                                      pattern: "[0-9]*",
                                      inputmode: "numeric", 
                                      autocomplete: "one-time-code", 
                                      autofocus: true,
                                      oninput: "this.value = this.value.slice(0, 6)",
                                      required: true,
                                      class: "input input-bordered h-20 w-full text-center text-4xl font-mono tracking-[0.3em] focus:input-primary transition-all shadow-inner placeholder:opacity-20"
                  end

                  div(class: "form-control mt-4") do
                    plain f.submit "Подтвердить и войти", 
                                  class: "btn btn-primary btn-lg w-full shadow-lg shadow-primary/30 text-base md:text-lg", 
                                  data: { turbo_submits_with: "..." }
                  end
                end

                # Нижняя панель действий
                div(class: "mt-8 pt-6 border-t border-base-content/5 text-center") do
                  a(href: auth_sign_path, class: "inline-flex items-center gap-2 text-xs link link-hover opacity-60 hover:opacity-100 transition-opacity") do
                    plain raw lucide_icon("arrow-left", class: "size-3")
                    plain "Изменить Email"
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
