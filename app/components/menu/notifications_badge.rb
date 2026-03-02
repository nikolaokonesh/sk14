class Components::Menu::NotificationsBadge < Phlex::HTML
  include Phlex::Rails::Helpers::DOMID

  def initialize(user:)
    @user = user
  end

  def view_template
    unread = @user.unread_notifications_count

    span(id: dom_id(@user, :notifications_badge), class: "absolute -top-1 -right-1") do
      if unread.positive?
        span(class: "badge badge-error badge-xs") { unread > 99 ? "99+" : unread.to_s }
      end
    end
  end
end
