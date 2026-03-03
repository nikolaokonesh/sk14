Rails.application.config.to_prepare do
  Noticed::Notification.include Noticed::NotificationExtensions
end
