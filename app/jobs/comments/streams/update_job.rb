class Comments::Streams::UpdateJob < ApplicationJob
  queue_as :default

  def perform(comment_id)
    comment = Comment.includes(entry: :root).find_by(id: comment_id)
    return unless comment&.entry

    comment.broadcast_replace_to [ comment.entry.root, :comments ],
      target: "entry_#{comment.entry.id}",
      renderable: Components::Comments::Card.new(entry: comment.entry, highlight: true) { |card| card.card_comment },
      layout: false
  end
end
