# app/jobs/cleanup_expired_posts_job.rb
class CleanupExpiredPostsJob < ApplicationJob
  queue_as :default

  def perform
    # Берем только те посты, у которых duration НЕ forever
    Post.where.not("setting->>'duration' = ?", "forever").find_each do |post|
      # Определяем время жизни поста на основе его выбора
      lifetime = case post.duration
      when "three"     then 3.days
      when "week"      then 1.week
      when "month"     then 1.month
      when "half_year" then 6.months
      when "year"      then 1.year
      else nil
      end

      # Если время с момента создания (created_at) больше, чем положено — удаляем
      if lifetime && post.created_at < lifetime.ago
        post.destroy
      end
    end
  end
end
