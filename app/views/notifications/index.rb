class Views::Notifications::Index < Views::Base
  def initialize(notifications:, pagy:)
    @notifications = notifications
    @pagy = pagy
  end

  def page_title = "Уведомления"
  def layout = Layout

  def view_template
    turbo_stream_from :notifications

    div(class: "w-full p-4 space-y-4") do
      div(class: "flex items-center justify-between") do
        h1(class: "text-2xl font-bold") { "Уведомления" }

        if Current.user.unread_notifications_count.positive?
          button_to "Отметить всё прочитанным",
            mark_all_as_read_notifications_path,
            method: :post,
            class: "btn btn-sm btn-outline"
        end
      end

      if @notifications.empty?
        p(class: "text-base-content/70") { "Пока уведомлений нет" }
      else
        render Views::Notifications::Page.new(notifications: @notifications, pagy: @pagy)
      end
    end
  end
end
