module Entry::Threading
  extend ActiveSupport::Concern

  included do
    before_validation :set_root_from_parent, if: :parent_id?
    after_create :set_self_as_root, unless: :root_id?

    validate :root_consistency, on: :update, if: :root_id_changed?
  end

  def participants
    User.where(id: descendants.select(:user_id)).or(User.where(id: user_id)).distinct
  end

  def all_comments
    descendants.where(entryable_type: Entry::COMMENT_TYPE)
  end

  def first_in_group?
    return true if parent_id.nil?

    prev_entry = parent.replies
                       .where("created_at < ?", created_at)
                       .order(created_at: :asc)
                       .last

    prev_entry.nil? || prev_entry.user_id != user_id
  end

  def last_in_group?
    next_entry = parent&.replies
                       &.where("created_at > ?", created_at)
                       &.order(created_at: :asc)
                       &.first

    next_entry.nil? || next_entry.user_id != user_id
  end

  def group_anchor_id
    scope = Entry.active.where(entryable_type: entryable_type)

    scope = if entryable_type == Entry::COMMENT_TYPE
      scope.where(root_id: root_id)
    else
      scope.where(parent_id: nil)
    end

    last_interruption_time = scope
                            .where.not(user_id: user_id)
                            .where("created_at < ?", created_at)
                            .order(created_at: :desc)
                            .pick(:created_at)
    query = scope.where(user_id: user_id)

    if last_interruption_time
      query = query.where("created_at > ?", last_interruption_time)
    end

    query.order(created_at: :asc).pick(:id) || id
  end

  private

  def set_root_from_parent
    self.root_id = parent.root_id
  end

  def set_self_as_root
    update_column(:root_id, id)
  end

  def root_consistency
    errors.add(:root_id, "cannot be changed once set root_id")
  end
end
