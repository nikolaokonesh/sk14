module User::Following
  extend ActiveSupport::Concern

  def follow(object)
    subscriptions.find_or_create_by(followable: object)
  end

  def unfollow(object)
    subscriptions.find_by(followable: object)&.destroy
  end

  def following?(object)
    subscriptions.exists?(followable: object)
  end

  def followed_user_ids
    subscriptions.where(followable_type: "User").pluck(:followable_id)
  end

  def followed_tag_ids
    subscriptions.where(followable_type: "Tag").pluck(:followable_id)
  end
end
