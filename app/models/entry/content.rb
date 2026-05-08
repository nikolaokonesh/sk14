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
    after_save_commit :update_cached_data
  end

  # ПУБЛИЧНЫЙ МЕТОД: Используется в Phlex компонентах
  # Возвращает объект-вариант (или nil), который Phlex превратит в URL
  def preview_variant(width: 200, height: 200)
    return nil unless preview_blob_id

    preview_blob.variant(
      resize_to_fill: [ width, height ],
      format: :webp,
      saver: { quality: 50 }
    )
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

    # 2. Магия: заменяем закрывающие теги блоков на текст + пробел
    processed_html = html.gsub(/<\/(h[1-6]|p|div|li)>/, " </\\1>")

    # 3. Превращаем в чистый текст
    full_plain_text = ActionController::Base.helpers.strip_tags(processed_html)
                                            .gsub(/\s+/, " ")
                                            .strip

    # 4. Формируем обрезанный заголовок
    new_title = truncated_title_from(full_plain_text)

    # Ищем ПЕРВОЕ изображение среди вложений
    first_image_attachment = content.embeds.find { |e| e.image? }
    new_preview_blob_id = first_image_attachment&.blob_id

    # 5. Считаем количество изображений
    new_images_count = content.embeds.select(&:image?).size

    # 6. Сохраняем изменения в базу (update_columns не вызывает коллбэки повторно)
    if title != new_title || images_count != new_images_count || preview_blob_id != new_preview_blob_id
      update_columns(
        title: new_title,
        images_count: new_images_count,
        preview_blob_id: new_preview_blob_id
      )

      # ПРОГРЕВ КЭША: Создаем сжатый файл сразу после сохранения.
      # Теперь первый посетитель страницы не будет ждать, пока сервер обработает 5МБ картинку.
      preview_variant&.processed if new_preview_blob_id
    end
  end

  # Логика умной обрезки текста по словам
  def truncated_title_from(plain_text)
    return plain_text if plain_text.length <= Entry::TITLE_PREVIEW_LENGTH

    stop_at = plain_text[0..Entry::TITLE_PREVIEW_LENGTH].rindex(" ") || Entry::TITLE_PREVIEW_LENGTH
    "#{plain_text[0...stop_at].strip}..."
  end
end
