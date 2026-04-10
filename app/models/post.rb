class Post < ApplicationRecord
  include FirstImage
  has_one :entry, as: :entryable, touch: true, dependent: :destroy

  has_rich_text :content
  validate :content_length

  private

  def content_length
    if content.to_plain_text.length < 10
      errors.add(:content, "Должен быть текст записи (минимум 10 сиволов)")
    end
  end
end
