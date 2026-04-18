class Post < ApplicationRecord
  broadcasts_refreshes
  include FirstImage
  has_one :entry, as: :entryable, touch: true, dependent: :destroy

  has_rich_text :content
  validates :content, presence: true
  validate :content_length

  has_delegated_json :setting, no_comments: false

  private

  def content_length
    plain_text = ActionController::Base.helpers.strip_tags(content.to_s).strip

    if plain_text.blank?
      errors.add(:content, "обязательно должен содержать текст")
    elsif plain_text.length < 10
      errors.add(:content, "Слишком короткий (минимум 10 сиволов текста)")
    end
  end
end
