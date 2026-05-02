# frozen_string_literal: true

class CleanupExpiredAdvertisementsJob < ApplicationJob
  queue_as :default

  def perform
    expired_ads = Advertisement.expired
    deleted_count = expired_ads.delete_all

    Turbo::StreamsChannel.broadcast_refresh_to(:entries) if deleted_count.positive?
  end
end
