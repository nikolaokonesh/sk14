class Components::Notifications::Item < Phlex::HTML
  include Phlex::Rails::Helpers::Routes
  include Phlex::Rails::Helpers::DOMID
  include Phlex::Rails::Helpers::ButtonTo

  def initialize(notification:)
    @notification = notification
  end

  def view_template
    div(id: dom_id(@notification), class: classes) do
      div(class: "space-y-1") do
        if notification_url
          a(href: notification_url, data: { turbo_frame: "_top" }, class: "hover:opacity-80") do
            p(class: "font-medium") { notification_title }
            p(class: "font-sm text-base-content/70") { notification_body }
          end
        else
          p(class: "font-medium") { notification_title }
          p(class: "font-sm text-base-content/70") { notification_body }
        end
      end

      div(class: "flex items-center gap-3") do
        p(class: "text-xs text-base-content/60") { @notification.created_at.strftime("%d.%m.%Y %H:%M") }
        if @notification.read_at.nil?
          button_to "Прочитать",
            mark_as_read_notification_path(@notification),
            method: :patch,
            class: "btn btn-xs btn-outline"
        else
          span(class: "badge badge-success badge-sm") { "Прочитано" }
        end
      end
    end
  end

  private

  def classes
    base = "rounded-xl border p-3 flex items-start justify-between gap-4"
    @notification.read_at.nil? ? "#{base} bg-base-200" : "#{base} opacity-80"
  end

  def notification_title
    @notification.event&.message.presence || fallback_param(:title) || "Новое уведомление"
  end

  def notification_body
    @notification.event&.body.presence || fallback_param(:body) || "Посмотреть подробнее"
  end

  def notification_url
    @notification.event&.url
  end

  def fallback_param(key)
    params = @notification.event&.params || {}
    params[key.to_s].presence || params[key].presence
  end
end
