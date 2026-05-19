# frozen_string_literal: true

module Entry::Comments
  extend ActiveSupport::Concern

  class_methods do
    def comments_for(root_entry)
      where(root_id: root_entry.id, entryable_type: Entry::COMMENT_TYPE)
        .includes(:user, :rich_text_content)
        .order(created_at: :asc)
    end
  end

  def comment?
    entryable_type == Entry::COMMENT_TYPE
  end
end
