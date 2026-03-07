class Comment < ApplicationRecord
  has_one :entry, as: :entryable, touch: true, dependent: :destroy

  has_rich_text :content

  validates :content, presence: { message: "Комментарий без текста!" }

  # after_create_commit :enqueue_create_broadcast
  after_update_commit :enqueue_update_broadcast
  after_destroy_commit :enqueue_destroy_broadcast

  def mentioned_user_ids
    return [] unless content&.body

    content.body.attachables.grep(User).map(&:id).uniq
  end

  private

  def enqueue_create_broadcast
    Comments::Streams::CreateJob.perform_later(id)
  end

  def enqueue_update_broadcast
    Comments::Streams::UpdateJob.perform_later(id)
  end

  def enqueue_destroy_broadcast
    return unless entry
    Comments::Streams::DestroyJob.perform_later(root_id: entry.root_id, entry_id: entry.id)
  end
end
