module Noticed::NotificationExtensions
  extend ActiveSupport::Concern

  included do
    after_destroy_commit :broadcast_update_to_bell
  end

  def broadcast_update_to_bell
    recipient.broadcast_notifications_badge_update!
  end
end
