# frozen_string_literal: true

class Components::Users::Mention < Phlex::HTML
  include Phlex::Rails::Helpers::StripTags
  include Phlex::Rails::Helpers::Sanitize
  include Phlex::Rails::Helpers::Routes
  register_value_helper :authenticated?
  def initialize(
    user:
  )
    @user = user
    @username = user.username
  end

  def view_template
    div(class: "dropdown dropdown-hover dropdown-top") do
      span(tabindex: 0) { "@#{@username}" }
      div(tabindex: -1, class: "dropdown-content bg-base-300 p-1") do
        div(class: "flex items-center gap-2") do
          render Components::Users::Avatar.new(user: @user, style: "size-10", text_size: "text-sm")
          plain div { sanitize(strip_tags(@user.name_full)) }
        end
        plain div(class: "px-2 leading-5") {
          plain div(class: "text-slate-500") { sanitize(strip_tags(@user.email)) } if authenticated?
          a(href: user_path(@user), class: "text-xs") { "Посмотреть профиль" }
        }
      end
    end
  end
end
