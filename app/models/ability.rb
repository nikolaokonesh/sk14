# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    can :read, :all

    return if Current.user.blank?

    user = Current.user

    if user.has_role?(:admin)
      can :manage, :all
    end

    if user.has_role?(:moderator)
      can :update, :all
      can :destroy, Comment
    end

    if user.has_role?(:ban)
      cannot :manage, :all
    end

    can :read, :all
    # can :manage, Post if user.has_role?(:moderator, Post)
    can :manage, Entry, user_id: user.id
    can :manage, Post do |post|
      post.entry.user_id == user.id
    end
    can :manage, Comment do |comment|
      comment.entry.user_id == user.id
    end
    # Define abilities for the user here. For example:
    #
    #   return unless user.present?
    #   can :read, :all
    #   return unless user.admin?
    #   can :manage, :all
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, published: true
    #
    # See the wiki for details:
    # https://github.com/CanCanCommunity/cancancan/blob/develop/docs/define_check_abilities.md
  end
end
