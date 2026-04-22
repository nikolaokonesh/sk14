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
    after_save_commit :update_cached_data, if: :post?
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

  # Основной метод синхронизации данных из ActionText в колонки Entry
  def update_cached_data
    # 1. Получаем чистый текст без лишних пробелов
    full_plain_text = content.to_plain_text.squish

    # 2. Формируем обрезанный заголовок для списка
    new_title = truncated_title_from(full_plain_text)

    # 3. Считаем количество изображений во вложениях
    # Мы используем count(&:image?), чтобы не делать лишних SQL запросов к Blobs
    new_images_count = content.embeds.select(&:image?).size

    # 4. Сохраняем в базу только если что-то реально изменилось
    # update_columns не вызывает валидации и коллбеки (очень быстро)
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
