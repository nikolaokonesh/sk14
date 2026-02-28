class Reaction < ApplicationRecord
  belongs_to :user
  belongs_to :entry

  EMOJIS = {
    like: "👍",
    heart: "❤️",
    fire: "🔥",
    smile: "😊",
    laugh: "😂",
    wow: "😮",
    crying: "😢",
    lowcrying: "😭",
    clown: "🤡",
    poop: "💩"
  }.freeze

  validates :content, inclusion: { in: EMOJIS.values }

  after_commit :broadcast_reaction_update

  private

  def broadcast_reaction_update
    broadcast_replace_to :entries,
      target: "reactions_entry_#{entry_id}",
      renderable: Components::Reactions::List.new(entry: entry),
      layout: false

    broadcast_replace_to [ entry.root, :comments ],
      target: "reactions_entry_#{entry_id}",
      renderable: Components::Reactions::List.new(entry: entry),
      layout: false
  end
end
