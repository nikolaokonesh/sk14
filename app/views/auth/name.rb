# frozen_string_literal: true

class Views::Auth::Name < Views::Auth
  def initialize(user:)
    @user = user
  end

  def page_title = "Как вас зовут?"

  def view_template
    div(class: "min-h-screen flex items-stretch md:items-center justify-center bg-base-100") do
      main(class: "relative w-full max-w-5xl md:p-4") do
        render Components::Shared::BgGradient.new(opacity: "opacity-100")
        div(
          class: "hero min-h-screen md:min-h-[600px] md:rounded-3xl overflow-hidden shadow-2xl relative flex flex-col"
        ) do
          # Затемняющий слой для глубины
          div(class: "absolute inset-0 bg-neutral/60 backdrop-blur-[3px]")

          div(class: "hero-content relative z-10 flex-col lg:flex-row gap-8 lg:gap-12 p-6 md:p-16 w-full") do
            # Левая часть: Приветствие
            div(class: "text-center lg:text-left text-neutral-content max-w-md") do
              div(class: "mb-6 inline-flex p-3 bg-white/10 rounded-2xl backdrop-blur-md") do
                plain raw lucide_icon("user", class: "size-10 text-info")
              end

              h1(class: "text-4xl md:text-6xl font-black tracking-tighter leading-tight mb-6") do
                plain "Давайте"
                br(class: "hidden md:block")
                span(class: "text-info ml-2 md:ml-0") { "знакомиться" }
              end

              p(class: "text-sm md:text-lg opacity-90 font-medium leading-relaxed") do
                plain "Представьтесь, чтобы другим пользователям было удобнее к вам обращаться. Ваше имя, псевдоним или акроним вашей организации."
                span(class: "block mt-2 text-xs md:text-sm opacity-60") { "Это не обязательно — вы можете сделать это позже." }
              end
            end

            # Правая часть: Форма
            div(class: "card bg-base-100/95 backdrop-blur w-full max-w-sm shrink-0 shadow-xl border border-white/10 sm:rounded-3xl") do
              div(class: "card-body p-6 md:p-8") do
                h2(class: "card-title text-xl md:text-2xl font-bold mb-4") { "Ваш профиль" }

                form_with(model: @user, url: auth_name_path(@user), method: :put, class: "space-y-6") do |f|
                  div(class: "form-control") do
                    label(class: "label p-2") do
                      span(class: "label-text font-bold") { "Имя" }
                    end

                    plain f.text_field :name,
                                      maxlength: 50,
                                      placeholder: "Иванов Иван",
                                      class: [
                                        "input input-bordered input-lg w-full focus:input-primary transition-all shadow-inner",
                                        { "input-error": @user.errors[:name].any? }
                                      ]

                    if @user.errors[:name].any?
                      label(class: "label") do
                        span(class: "label-text-alt text-error font-medium") { @user.errors[:name].join(", ") }
                      end
                    end
                  end

                  div(class: "flex flex-col gap-3 mt-4") do
                    plain f.submit "Сохранить и войти", class: "btn btn-primary btn-lg w-full shadow-lg shadow-primary/30"

                    # Кнопка пропуска
                    a(href: root_path, class: "btn btn-ghost btn-md w-full opacity-60 hover:opacity-100 transition-opacity") do
                      "Пропустить этот шаг"
                    end
                  end
                end

                div(class: "mt-6 text-center") do
                  p(class: "text-[10px] opacity-40 uppercase tracking-widest") do
                    "Вы всегда можете изменить имя в настройках"
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
