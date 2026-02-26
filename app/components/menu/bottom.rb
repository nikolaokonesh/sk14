# frozen_string_literal: true

class Components::Menu::Bottom < Components::Base
  def view_template
    a(href: root_path, class: "mx-auto p-2 active:text-red-500") { lucide_icon("home") }
    a(href: tags_path, class: "mx-auto p-2 active:text-red-500") { lucide_icon("tag") }
    a(href: new_entry_path, class: "mx-auto p-2 active:text-red-500", data: { turbo_frame: "entry_modal" }) { lucide_icon("circle-plus", "stroke-width" => 2.5) }

    if authenticated? && Current.user
      a(href: notifications_path, class: "mx-auto p-2 active:text-red-500 relative") do
        span { lucide_icon("bell") }
        unread = Current.user.unread_notifications_count
        if unread.positive?
          span(class: "absolute -top-1 -right-1 badge badge-error badge-xs") { unread > 99 ? "99+" : unread.to_s }
        end
      end
      a(href: user_path(Current.user), class: "mx-auto active:text-red-500 p-2") do
        render Components::Users::Avatar.new(user: Current.user)
      end
    else
      a(href: auth_path, class: "mx-auto p-2 active:text-red-500") { lucide_icon("bell") }
      a(href: auth_path, class: "mx-auto p-2 active:text-red-500") { lucide_icon("user") }
    end
  end
end
