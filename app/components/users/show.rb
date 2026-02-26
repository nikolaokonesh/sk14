# frozen_string_literal: true

class Components::Users::Show < Components::Base
  def initialize(
    user:
  )
    @user = user
  end

  def view_template
    div(class: "w-full px-2") do
      div(class: "flex items-center w-full") do
        render Components::Users::Avatar.new(user: @user, style: "size-24", text_size: "text-2xl")
        plain div(class: "px-2 leading-5") {
          plain div { sanitize(strip_tags(@user.name_full)) }
          plain div(class: "text-slate-500") { sanitize(strip_tags(@user.email)) } if authenticated?
        }
        div(class: "w-full flex") do
          if authenticated? && Current.user == @user
            a(href: edit_user_path(@user), class: "text-white text-lg px-2") { lucide_icon("pencil") }
            div(class: "ml-auto") do
              a(href: auth_path, data: { turbo_method: :delete, turbo_confirm: "Вы уверены что хотите выйти?" }, class: "text-lg") { "Выйти" }
            end
          end
        end
      end
    end
  end
end
