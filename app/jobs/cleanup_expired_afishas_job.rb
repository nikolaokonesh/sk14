class CleanupExpiredAfishasJob < ApplicationJob
  queue_as :default

  def perform
    # Ищем афиши, время которых вышло (event_date + duration < сейчас),
    # но которые еще не помечены как завершенные.
    expired_posts = Post.where(is_afisha: true, manual_finished: false)
                        .where("datetime(event_date, '+' || event_duration || ' days') < ?", Time.current.utc)

    return if expired_posts.none?

    expired_posts.find_each do |post|
      # "Нажимаем" кнопку программно
      post.update(
        manual_finished: true,
        finished_at: Time.current.utc
      )

      # Если нужно обновить интерфейс у пользователей онлайн через Turbo
      Turbo::StreamsChannel.broadcast_refresh_to(:entries)
    end
  end
end
