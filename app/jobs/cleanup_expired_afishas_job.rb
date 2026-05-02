class CleanupExpiredAfishasJob < ApplicationJob
  queue_as :default

  def perform
    changed = false

    Post.where(is_afisha: true).find_each do |post|
      next_status = post.calculate_afisha_status
      attrs = {}

      if post.afisha_status != next_status.to_s
        attrs[:afisha_status] = next_status.to_s
      end

      next if attrs.empty?

      post.update_columns(attrs.merge(updated_at: Time.current))
      changed = true
    end

    Turbo::StreamsChannel.broadcast_refresh_to(:entries) if changed
  end
end
