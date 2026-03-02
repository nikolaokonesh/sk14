class NotificationsController < ApplicationController
  before_action :set_notification, only: :mark_as_read

  def index
    notification_scope = Current.user.notifications
                                     .includes(:event)
                                     .order(created_at: :desc)

    @pagy, @notifications = pagy_countless(notification_scope)

    if params[:page].present?
      render Views::Notifications::Page.new(notifications: @notifications, pagy: @pagy), layout: false
    else
      render Views::Notifications::Index.new(notifications: @notifications, pagy: @pagy)
    end
  end

  def mark_as_read
    @notification.update(read_at: Time.current) if @notification.read_at.nil?

    Current.user.broadcast_notifications_badge_update!

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream:
          turbo_stream.replace(@notification,
                              renderable: Components::Notifications::Item.new(notification: @notification),
                              layout: false)
      end
      format.html { redirect_to notifications_path, notice: "Уведомление прочитано" }
    end
  end

  def mark_all_as_read
    Current.user.notifications.where(read_at: nil).update_all(read_at: Time.current)
    Current.user.broadcast_notifications_badge_update!

    redirect_to notifications_path, notice: "Все уведомления отмечены как прочитанные"
  end

  private

  def set_notification
    @notification = Current.user.notifications.find(params[:id])
  end
end
