# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    can :read, :all

    return if user.blank?

    @user = user
    @role_names = user.roles.map(&:name)

    apply_admin_permissions if has_role?("admin")
    apply_moderator_permissions if has_role?("moderator")

    return apply_banned_permissions if has_role?("ban")

    apply_owner_permissions
  end

  private

  attr_reader :user, :role_names

  def has_role?(role_name)
    role_names.include?(role_name)
  end

  def apply_admin_permissions
    can :manage, :all
    can :view_trash, User
    can :restore, Entry
    can :hard_destroy, Entry
  end

  def apply_moderator_permissions
    can :update, :all
  end

  def apply_banned_permissions
    cannot :manage, :all
  end

  def apply_owner_permissions
    can :view_trash, User, id: user.id
    can :restore, Entry, user_id: user.id
    can :manage, Entry, user_id: user.id
    can :hard_destroy, Entry, user_id: user.id

    can :manage, [Post, Advertisement] do |record|
      record.entry.user_id == user.id
    end
  end
end
