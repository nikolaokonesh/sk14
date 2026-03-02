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

  has_many :notifications, as: :recipient, class_name: "Noticed::Notification", dependent: :destroy

  has_many :entry_read_states, dependent: :destroy

  def mark_entry_as_read!(entry)
    root_entry = entry.root || entry
    now = Time.current

    state = entry_read_states.find_by(entry: root_entry)
    latest_comment_at = root_entry.all_comments.maximum(:created_at)
    already_read = state&.post_read_at.present? &&
                   state&.comments_read_at.present? &&
                   (latest_comment_at.nil? || state.comments_read_at >= latest_comment_at)

    return if already_read

    state ||= entry_read_states.new(entry: root_entry)
    state.post_read_at = now
    state.comments_read_at = now
    state.save!

    notifications.where(read_at: nil).includes(:event).find_each do |notification|
      params = notification.event&.params || {}
      root_entry_id = params["root_entry_id"] || params[:root_entry_id]
      next unless root_entry_id.to_i == root_entry.id

      notification.update_columns(read_at: now, updated_at: now)
    end

    broadcast_read_state_update!(root_entry)
  end

  def unread_comments_count_for(entry)
    root_entry = entry.root || entry
    state = entry_read_states.find_by(entry: root_entry)
    from_time = state&.comments_read_at || root_entry.created_at

    root_entry.all_comments.where("created_at > ?", from_time).where.not(user_id: id).count
  end

  def show_unread_comments_count_for?(entry)
    root_entry = entry.root || entry
    entry.user_id == id || entries.where(entryable_type: "Comment", root_id: root_entry.id).exists?
  end

  def unread_notifications_count
    notifications.where(read_at: nil).count
  end

  def broadcast_notifications_badge_update!
    broadcast_replace_to(
      [ :user, id ],
      target: [ self, :notifications_badge ],
      renderable: Components::Menu::NotificationsBadge.new(user: self),
      layout: false
    )
  end

  def broadcast_read_state_update!(entry)
    broadcast_replace_to(
      [ :user, id ],
      target: [ entry, :read_state_badge ],
      renderable: Components::Entries::ReadStateBadge.new(entry: entry, user: self),
      layout: false
    )
  end

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
