class CleanupExpiredAfishasJob < ApplicationJob
  queue_as :default

  def perform(post_id)
    post = Post.find_by(id: post_id)
    return unless post&.is_afisha?

    now = Time.current
    new_status = post.calculate_afisha_status(now).to_s

    if post.afisha_status != new_status
      post.update_columns(afisha_status: new_status, updated_at: now)
      post.schedule_status_refresh
      Turbo::StreamsChannel.broadcast_refresh_to(:entries)
    end
  end
end
