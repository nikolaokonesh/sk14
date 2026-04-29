class CleanupExpiredAfishasJob < ApplicationJob
  queue_as :default

  def perform
    # Просто ищем всё, что должно было закончиться к текущему моменту
    expired_posts = Post.where(is_afisha: true, manual_finished: false)
                        .where("finished_at < ?", Time.current)

    return if expired_posts.none?

    expired_posts.find_each do |post|
      post.update(manual_finished: true) # finished_at у нас уже записан
    end

    Turbo::StreamsChannel.broadcast_refresh_to(:entries)
  end
end
