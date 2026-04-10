# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    can :read, :all

    return if Current.user.blank?

    user = Current.user

    if user.has_role?(:admin)
      can :manage, :all
      can :view_trash, User
      can :restore, Entry
      can :hard_destroy, Entry
    end

    if user.has_role?(:moderator)
      can :update, :all
      # can :destroy, Comment
    end

    if user.has_role?(:ban)
      cannot :manage, :all
    end

    can :read, :all

    can :view_trash, User, id: user.id
    can :restore, Entry, user_id: user.id

    can :manage, Entry, user_id: user.id
    can :hard_destroy, Entry, user_id: user.id

    can :manage, Post do |post|
      post.entry.user_id == user.id
    end

    # can :manage, Comment do |comment|
    #   comment.entry.user_id == user.id
    # end
  end
end
