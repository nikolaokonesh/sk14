class User < ApplicationRecord
  rolify
  has_person_name

  include Name
  include Slug
  include Validate
  include ReadState
  include Following
  include Authentication
  include Stats

  include ActionText::Attachable

  has_many :sessions, dependent: :destroy
  has_many :access_tokens, dependent: :destroy
  has_one :avatar, class_name: "User::Avatar", dependent: :destroy

  # Те, на кого подписан данный пользователь
  has_many :subscriptions, dependent: :destroy
  # Удобные Геттеры для конкретных типов подписок
  has_many :followed_users, through: :subscriptions, source: :followable, source_type: "User"
  has_many :followed_tags, through: :subscriptions, source: :followable, source_type: "Tag"
  # Те, кто подписан на данного пользователя (как на followable)
  has_many :passive_subscriptions, as: :followable, class_name: "Subscription", dependent: :destroy
  has_many :followers, through: :passive_subscriptions, source: :user

  normalizes :email, with: ->(e) { e.strip.downcase }
  validates :email, presence: true, uniqueness: true

  has_many :entries, dependent: :destroy
  has_many :posts, through: :entries, source: :entryable, source_type: "Post"
  has_many :comments, through: :entries, source: :entryable, source_type: "Comment"

  has_many :notifications, as: :recipient, class_name: "Noticed::Notification", dependent: :destroy
  has_many :entry_read_states, dependent: :destroy

  def content_type
    "application/vnd.actiontext.mention"
  end
end
