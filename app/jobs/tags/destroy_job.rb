class Tags::DestroyJob < ApplicationJob
  queue_as :default

  # Удаление тэгов не привязанные к существующим постам
  def perform(*args)
    # Вариант 1
    unused_tags = Tag.where.not(id: PostKeyword.select(:tag_id).where.not(post_id: nil))

    # Вариант 2
    # unused_tags = Tag.joins("LEFT JOIN post_keywords ON post_keywords.tag_id = tags.id")
    #             .joins("LEFT JOIN posts ON posts.id = post_keywords.post_id")
    #             .where("posts.id IS NULL")

    count = unused_tags.count
    unused_tags.delete_all
    puts "Deleted Tags NULL posts: #{count}"
  end
end
