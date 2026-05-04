class Ability
  include CanCan::Ability

  def initialize(user)
    can :read, :all

    return if user.blank?

    # Кэшируем имена ролей в массив строк, чтобы не дергать базу
    user_roles = user.roles.map(&:name)

    if user_roles.include?("admin")
      can :manage, :all
      can :view_trash, User
      can :restore, Entry
      can :hard_destroy, Entry
    end

    if user_roles.include?("moderator")
      can :update, :all
    end

    if user_roles.include?("ban")
      cannot :manage, :all
      return # Если забанен, дальше проверки на владение ресурсами не нужны
    end

    # Права для владельца контента
    can :view_trash, User, id: user.id
    can :restore, Entry, user_id: user.id
    can :manage, Entry, user_id: user.id
    can :hard_destroy, Entry, user_id: user.id

    # Для Delegated Types (Post, Advertisement)
    can :manage, [Post, Advertisement] do |record|
      record.entry.user_id == user.id
    end
  end
end
