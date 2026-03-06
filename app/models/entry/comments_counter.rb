module Entry::CommentsCounter
  extend ActiveSupport::Concern

  included do
    after_create_commit :increment_root_comments_count, if: :comment?
    after_destroy_commit :decrement_root_comments_count, if: :comment?
    after_update_commit :move_root_comments_count, if: :comment_root_changed?
  end

  private

  def comment?
    entryable_type == Entry::COMMENT_TYPE
  end

  def increment_root_comments_count
    return unless root_id

    Entry.where(id: root_id).update_all("comments_count = COALESCE(comments_count, 0) + 1")
  end

  def decrement_root_comments_count
    return unless root_id

    Entry.where(id: root_id).update_all("comments_count = CASE WHEN COALESCE(comments_count, 0) > 0 THEN COALESCE(comments_count, 0) - 1 ELSE 0 END")
  end

  def move_root_comments_count
    previous_root_id, new_root_id = saved_change_to_root_id

    Entry.where(id: previous_root_id).update_all("comments_count = CASE WHEN COALESCE(comments_count, 0) > 0 THEN COALESCE(comments_count, 0) - 1 ELSE 0 END") if previous_root_id
    Entry.where(id: new_root_id).update_all("comments_count = COALESCE(comments_count, 0) + 1") if new_root_id
  end

  def comment_root_changed?
    comment? && saved_change_to_root_id?
  end
end
