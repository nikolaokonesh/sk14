# frozen_string_literal: true

class Components::Menu::Topbar < Components::Base
  def view_template
    div(class: "navbar bg-base-100 shadow-sm") do
      div(class: "navbar-start") do
        div(class: "dropdown") do
          div(tabindex: "0", role: "button", class: "btn btn-ghost btn-circle") do
            lucide_icon("menu")
          end
          ul(tabindex: "-1", class: "menu menu-sm dropdown-content bg-base-100 rounded-box z-20 mt-3 w-52 p-2 shadow") do
            li do
              a(href: root_path) { "Главное" }
            end
            li do
              a(href: new_entry_path) { "Добавить" }
            end
            li do
              a(href: root_path) { "Настройки" }
            end
            li do
              if current_user
                a(href: auth_sign_path, data: { turbo_method: :delete, turbo_confirm: "Вы уверены что хотите выйти?" }) { "Выйти" }
              else
                a(href: auth_sign_path) { "Войти" }
              end
            end
          end
        end
      end
      div(class: "navbar-center") do
        a(class: "btn btn-ghost text-xl") do
          plain img(src: image_path("logo.png"), class: "size-12", loading: "lazy")
          plain "SK14"
        end
      end
      div(class: "navbar-end") do
        button(class: "btn btn-ghost btn-circle") do
          lucide_icon("search")
        end
        button(class: "btn btn-ghost btn-circle") do
          div(class: "indicator") do
            plain raw lucide_icon("bell")
            span(class: "badge badge-xs badge-primary indicator-item") { }
          end
        end
      end
    end
  end
end
