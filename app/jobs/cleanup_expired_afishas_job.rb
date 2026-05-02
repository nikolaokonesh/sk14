class CleanupExpiredAfishasJob < ApplicationJob
  queue_as :default

  def perform
    now = Time.current
    upcoming_cutoff = now + 7.days
    finished_cutoff = 1.hour.ago

    candidates = Post.where(is_afisha: true)
                     .where.not(event_date: nil)
                     .where("event_date <= ?", upcoming_cutoff)
                     .where("afisha_status IS DISTINCT FROM ? OR finished_at >= ?", "finished", finished_cutoff)

    changed = 0

    candidates.find_each do |post|
      next_status = post.calculate_afisha_status(now).to_s
      next if post.afisha_status == next_status

      post.update_columns(afisha_status: next_status, updated_at: now)
      changed += 1
    end

    Turbo::StreamsChannel.broadcast_refresh_to(:entries) if changed.positive?
  end
end
