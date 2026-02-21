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
    clown: "🤡",
    poop: "💩"
  }.freeze

  validates :content, inclusion: { in: EMOJIS.values }

  # Обновляем блок реакций у всех пользователей мгновенно
  after_commit :broadcast_reaction_update

  private

  def broadcast_reaction_update
    # root_id позволяет транслировать в нужную ветку комментариев или ленту
    broadcast_replace_to [ entry.root, :comments ],
      target: "reactions_entry_#{entry_id}",
      renderable: Components::Reactions::List.new(entry: entry),
      layout: false
  end
end
