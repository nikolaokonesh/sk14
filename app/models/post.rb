class Post < ApplicationRecord
  include FirstImage
  has_one :entry, as: :entryable, touch: true, dependent: :destroy

  has_rich_text :content
  validates :content, presence: { message: "Содержание не может быть без текста!" }

  after_save :update_truncated_content

  private

  def update_truncated_content
    return unless content.present?

    plain_text = if content.respond_to?(:to_plain_text)
      content.to_plain_text
    else
      ActionController::Base.helpers.strip_tags(content.to_s).squish
    end

    truncated = if plain_text.length > 500
      space_index = plain_text[0..500].rindex(" ") || 500
      plain_text[0..space_index] + "..."
    else
      plain_text
    end

    update_column(:title, truncated)
  end
end
