# frozen_string_literal: true

module Entry::Content
  extend ActiveSupport::Concern

  included do
    # Подключаем ActionText
    has_rich_text :content

    # Валидации
    validates :content, presence: true
    validate :content_length

    # Кешируем данные в колонки таблицы entries после сохранения
    # Используем after_save_commit, чтобы ActionText гарантированно успел сохранить вложения
    after_save_commit :update_cached_data
  end

  private

  # Валидация длины чистого текста (без учета HTML-тегов)
  def content_length
    return if content.nil?

    plain_text = content.to_plain_text.strip
    if plain_text.blank?
      errors.add(:content, "должен содержать текст")
    elsif plain_text.length < 10
      errors.add(:content, "слишком короткий (минимум 10 символов текста)")
    end
  end

def update_cached_data
  # 1. Берем HTML контент
  html = content.to_s

  # 2. Магия: заменяем закрывающие теги блоков (h1-h6, p, div, li)
  # на их содержимое + пробел. Это гарантирует разрыв между словами.
  processed_html = html.gsub(/<\/(h[1-6]|p|div|li)>/, " </\\1>")

  # 3. Теперь превращаем в текст.
  # Используем strip и замену множественных пробелов
  full_plain_text = ActionController::Base.helpers.strip_tags(processed_html)
                                          .gsub(/\s+/, " ")
                                          .strip

  # 4. Формируем обрезанный заголовок
  new_title = truncated_title_from(full_plain_text)

  # 5. Считаем количество изображений
  new_images_count = content.embeds.select(&:image?).size

  # 6. Сохраняем
  if title != new_title || images_count != new_images_count
    update_columns(title: new_title, images_count: new_images_count)
  end
end


  # Логика умной обрезки текста по словам
  def truncated_title_from(plain_text)
    return plain_text if plain_text.length <= Entry::TITLE_PREVIEW_LENGTH

    # Ищем индекс последнего пробела в пределах лимита, чтобы не резать слово пополам
    stop_at = plain_text[0..Entry::TITLE_PREVIEW_LENGTH].rindex(" ") || Entry::TITLE_PREVIEW_LENGTH
    "#{plain_text[0...stop_at].strip}..."
  end
end
