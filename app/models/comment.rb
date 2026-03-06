class Comment < ApplicationRecord
  has_one :entry, as: :entryable, touch: true, dependent: :destroy

  has_rich_text :content

  validates :content, presence: { message: "Комментарий без текста!" }

  after_create :broadcast_comments_counter
  after_create_commit :broadcast_to_create_chat
  after_create_commit :broadcast_read_state_badges
  after_update_commit :broadcast_to_update_chat
  after_destroy_commit :broadcast_to_destroy_chat

  def mentioned_user_ids
    return [] unless content&.body

    content.body.attachables.grep(User).map(&:id).uniq
  end

  private

  def broadcast_read_state_badges
    root_entry = entry&.root
    return unless root_entry

    user_ids = root_entry.all_comments.select(:user_id).distinct.pluck(:user_id)
    user_ids << root_entry.user_id

    User.where(id: user_ids.uniq).find_each do |user|
      user.broadcast_read_state_update!(root_entry)
      user.broadcast_notifications_badge_update!
    end
  end

  def broadcast_to_create_chat
    broadcast_render_to(
      [ entry.root, :comments ],
      renderable: Views::Comments::Streams::Create.new(entry: entry),
      layout: false
    )
  end

  def broadcast_to_update_chat
    broadcast_replace_to [ entry.root, :comments ],
      target: "entry_#{entry.id}",
      renderable: Components::Comments::Card.new(entry: entry, highlight: true) { |card| card.card_comment },
      layout: false
  end

  def broadcast_to_destroy_chat
    broadcast_remove_to [ entry.root, :comments ], target: "entry_#{entry.id}"
    broadcast_read_state_badges
    broadcast_comments_counter
  end

  def broadcast_comments_counter
    broadcast_replace_to :entries, target: [ entry.root, :comments_counter ], renderable: Components::Entries::CommentsCounter.new(entry: entry.root), layout: false
  end
end
