class Post < ApplicationRecord
  belongs_to :district
  belongs_to :category, optional: true
  belongs_to :user, optional: true

  has_rich_text :content

  enum :post_type, {
    news: "news",
    gratitude: "gratitude",
    question: "question",
    article: "article",
    announcement: "announcement"
  }, validate: true

  enum :action_type, {
    sale: "sale",
    purchase: "purchase",
    exchange: "exchange",
    gift: "gift",
    service: "service",
    rent: "rent"
  }, prefix: true

  validates :content, presence: true
  validates :post_type, presence: true

  before_create :set_published_at

  scope :recent, -> { order(published_at: :desc) }

  def plain_text
    content.to_plain_text.strip
  end

  def action_type_human
    case action_type
    when "sale" then "💰 Продажа"
    when "purchase" then "🔍 Ищу / Куплю"
    when "exchange" then "🔄 Обмен"
    when "gift" then "🎁 Даром"
    when "service" then "🛠️ Услуги"
    when "rent" then "🔑 Аренда"
    else ""
    end
  end

  # Приоритет типов постов (1 - самый высокий, 5 - самый низкий)
  PRIORITY_MAP = {
    "news" => 1,
    "gratitude" => 2,
    "question" => 3,
    "article" => 4,
    "announcement" => 5
  }.freeze

  def priority
    PRIORITY_MAP[post_type] || 5
  end

  private

  def set_published_at
    self.published_at ||= Time.current
  end
end