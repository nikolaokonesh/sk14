# app/jobs/cleanup_expired_posts_job.rb
class CleanupExpiredPostsJob < ApplicationJob
  queue_as :default

  # Определяем правила очистки в константе, чтобы не плодить "магические строки"
  CLEANUP_RULES = {
    "three"     => 3.days,
    "week"      => 1.week,
    "month"     => 1.month,
    "half_year" => 6.months,
    "year"      => 1.year
  }.freeze

  def perform
    CLEANUP_RULES.each do |key, interval|
      # Ищем только те посты, срок которых реально истёк
      # Используем json_extract для SQLite, чтобы попасть точно в цель
      expired_posts = Post.where("json_extract(setting, '$.duration') = ?", key)
                          .where("created_at < ?", interval.ago)

      expired_posts.find_each do |post|
        # Перемещаем в корзину (как в логике контроллера)
        # Это вызовет touch: true для Entry и обновит кэш/стримы
        post.entry.update(trash: true, trash_data: Time.current)

        # Если всё же нужно удалять совсем, используй post.destroy
      end
    end
  end
end
