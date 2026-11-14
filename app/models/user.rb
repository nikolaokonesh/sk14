class User < ApplicationRecord
  rolify
  extend FriendlyId
  has_person_name

  has_many :access_tokens, dependent: :destroy
  has_many :sessions, dependent: :destroy
  has_many :posts, dependent: :nullify

  friendly_id :slug_candidates, use: [:slugged, :history]

  validates :slug, presence: true, uniqueness: true

  validate :phone_or_email_present

  validates :phone,
            uniqueness: true,
            allow_nil: true,
            format: {
              with: /\A\+7\d{10,14}\z/,
              message: "должен быть в формате +79991234567 или 89991234567"
            },
            if: -> { phone.present? }

  validates :email,
            uniqueness: true,
            allow_nil: true,
            format: {
              with: URI::MailTo::EMAIL_REGEXP,
              message: "должен быть валидным email"
            },
            if: -> { email.present? }

  before_validation :normalize_phone, if: -> { phone.present? }
  before_validation :normalize_email, if: -> { email.present? }
  before_create :generate_otp_secret

  # ❌ УБРАНО: set_slug_from_phone_or_email

  # Кандидаты для slug
  def slug_candidates
    if name_present? && username.parameterize.present?
      [
        username,
        "#{username}-#{id || rand(100..999)}"
      ]
    else
      # Несколько кандидатов, чтобы friendly_id не дошёл до UUID
      Array.new(5) { "user#{rand(100..999_999)}" }
    end
  end

  def should_generate_new_friendly_id?
    slug.blank? || first_name_changed? || last_name_changed?
  end

  def name_present?
    first_name.present?
  end

  # Публичное имя: инициал + фамилия, либо просто имя, либо userNNN
  def username(type = :full)
    return slug unless name_present?
    return name.first if last_name.blank?

    name.respond_to?(type) ? name.public_send(type) : name.full
  end

  # Для интерфейса. Контакты больше не показываем публично
  def display_name
    name_present? ? name.full : slug
  end

  # Аватар без картинок — ноль байт трафика
  def avatar_text
    name_present? ? name.initials : "👤"
  end

  # Контакты — только для личных настроек, не для публичной страницы
  def contact_info
    email || phone
  end

  def contact_type
    email.present? ? :email : :phone
  end

  def auth_code
    totp.now
  end

  def valid_auth_code?(code)
    totp.verify(code, drift_behind: 300).present?
  end

  private

  def phone_or_email_present
    if phone.blank? && email.blank?
      errors.add(:base, "Укажите номер телефона или email")
    end
  end

  def normalize_phone
    return unless phone.present?

    cleaned = phone.gsub(/\D/, "")

    if cleaned.start_with?("8") && cleaned.length >= 11
      self.phone = "+7#{cleaned[1..-1]}"
    elsif cleaned.start_with?("7")
      self.phone = "+#{cleaned}"
    else
      self.phone = "+#{cleaned}"
    end
  end

  def normalize_email
    self.email = email.downcase.strip if email.present?
  end

  def generate_otp_secret
    self.otp_secret = ROTP::Base32.random(16)
  end

  def totp
    ROTP::TOTP.new(otp_secret, issuer: "sk14")
  end
end