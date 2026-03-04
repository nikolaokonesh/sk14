module Entry::Reactions
  extend ActiveSupport::Concern

  def reaction_summary
    reactions.group(:content).count
  end

  def reacted_with?(user, emoji)
    return false unless user

    reactions.exists?(user: user, content: emoji)
  end

  def current_reaction_for(user)
    reactions.find_by(user: user)
  end
end
