class Components::Notifications::Item < Phlex::HTML
  def initialize(notification:)
    @notification = notification
  end

  def view_template
    div(id: dom_id(@notification), class: classes) do
      div(class: "space-y-1") do
        p(class: "font-medium") { notification_title }
        p(class: "text-sm text-base-content/70") { notification_body }
      end

      div(class: "flex items-center gap-3") do
        p(class: "text-xs text-base-content/60") { @notification.created_at.strftime("%d.%m.%Y %H:%M") }
        if @notification.read_at.nil?
          button_to "Прочитано",
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
    params = @notification.event&.params || {}
    params["title"].presence || params[:title].presence || "Новое уведомление"
  end

  def notification_body
    params = @notification.event&.params || {}
    params["body"].presence || params[:body].presence || "Откройте уведомление, чтобы посмотреть подробнее"
  end
end
