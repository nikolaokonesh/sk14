module Entry::Content
  extend ActiveSupport::Concern

  included do
    has_rich_text :content
    validates :content, presence: true
    validate :content_length

    # Используем after_save_commit, чтобы гарантировать, что rich_text уже в базе
    after_save_commit :update_truncated_content, if: :post?
  end

  private

  def content_length
    # Оптимизация: берем plain_text один раз
    return if content.nil?

    text = content.to_plain_text.strip
    if text.blank?
      errors.add(:content, "должен содержать текст")
    elsif text.length < 10
      errors.add(:content, "Слишком короткий (минимум 10)")
    end
  end

  def update_truncated_content
    # Чтобы не уйти в рекурсию after_commit -> update,
    # проверяем, отличается ли новый обрезанный текст от того, что уже в базе
    new_title = truncated_title_from(content.to_plain_text.squish)

    if title != new_title
      update_column(:title, new_title)
    end
  end

  def truncated_title_from(plain_text)
    return plain_text if plain_text.length <= Entry::TITLE_PREVIEW_LENGTH

    # Ищем пробел, чтобы не резать слово
    stop_at = plain_text[0..Entry::TITLE_PREVIEW_LENGTH].rindex(" ") || Entry::TITLE_PREVIEW_LENGTH
    "#{plain_text[0...stop_at].strip}..."
  end
end
