class Comment < ApplicationRecord
  has_one :entry, as: :entryable, touch: true, dependent: :destroy

  has_rich_text :content

  validates :content, presence: { message: "Комментарий без текста!" }

  # after_create_commit :broadcast_to_create_chat
  after_update_commit :broadcast_to_update_chat
  after_destroy_commit :broadcast_to_destroy_chat

  def mentioned_user_ids
    return [] unless content&.body

    content.body.attachables.grep(User).map(&:id).uniq
  end

  private

  def broadcast_to_create_chat
    broadcast_render_to(
      [ entry.root, :comments ],
      renderable: Views::Comments::Streams::Create.new(entry: entry),
      layout: false
    )

    # broadcast_append_to [ entry.root, :comments ],
    #   target: [ entry.root, :comments_list ],
    #   renderable: Components::Comments::Card.new(entry: entry, is_last_in_group: true, highlight: true, class_target: "last-comment") { |card| card.card_comment },
    #   layout: false
    # previous_comment = entry.root.replies.where.not(id: entry.id).last
    # if previous_comment && previous_comment.user_id == entry.user_id
    #   broadcast_replace_to [ entry.root, :comments ],
    #     target: "entry_#{previous_comment.id}",
    #     renderable: Components::Comments::Card.new(entry: previous_comment, is_last_in_group: false) { |card| card.card_comment },
    #     layout: false
    # end
  end

  def broadcast_to_update_chat
    broadcast_replace_to [ entry.root, :comments ],
      target: "entry_#{entry.id}",
      renderable: Components::Comments::Card.new(entry: entry, highlight: true) { |card| card.card_comment },
      layout: false
  end

  def broadcast_to_destroy_chat
    broadcast_remove_to [ entry.root, :comments ], target: "entry_#{entry.id}"
  end
end
