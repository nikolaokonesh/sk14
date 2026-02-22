class User < ApplicationRecord
  rolify
  has_person_name

  include Name
  include Slug
  include Validate

  include ActionText::Attachable
  def content_type
    "application/vnd.actiontext.mention"
  end

  before_create :generate_otp_secret
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
  def follow(object)
    subscriptions.find_or_create_by(followable: object)
  end
  def unfollow(object)
    subscriptions.find_by(followable: object)&.destroy
  end
  def following?(object)
    subscriptions.exists?(followable: object)
  end

  normalizes :email, with: ->(e) { e.strip.downcase }
  validates :email, presence: true, uniqueness: true

  def auth_code
    totp.now
  end

  def valid_auth_code?(code)
    totp.verify(code, drift_behind: 300).present?
  end

  has_many :entries, dependent: :destroy
  has_many :posts, through: :entries, source: :entryable, source_type: "Post"
  has_many :comments, through: :entries, source: :entryable, source_type: "Comment"

  def trash_size
    self.entries.where(entryable_type: "Post").inactive.count
  end
  def entries_size
    self.entries.where(entryable_type: "Post").active.count
  end

  def followed_user_ids
    subscriptions.where(followable_type: "User").pluck(:followable_id)
  end

  def followed_tag_ids
    subscriptions.where(followable_type: "Tag").pluck(:followable_id)
  end

  private

    def generate_otp_secret
      self.otp_secret = ROTP::Base32.random(16)
    end

    def totp
      ROTP::TOTP.new(otp_secret, issuer: "sk14")
    end
end
