# frozen_string_literal: true

module Entry::Content
  extend ActiveSupport::Concern

  included do
    # Подключаем ActionText
    has_rich_text :content

    # Валидации
    validates :content, presence: true
    validate :content_length

    # 1. Текст кешируем ПЕРЕД сохранением.
    # Это гарантирует, что заголовок попадет в базу в первом же INSERT запросе.
    before_save :cache_text_data, if: -> { content.changed? }

    # 2. Картинки кешируем ПОСЛЕ коммита.
    # На этом этапе ActionText уже точно привязал вложения к записи.
    after_save_commit :cache_images_data
  end

  # ПУБЛИЧНЫЙ МЕТОД: Используется в Phlex компонентах
  def preview_variant(width: 400, height: 400)
    return nil unless preview_blob_id

    preview_blob.variant(
      resize_to_fill: [ width, height ],
      format: :webp,
      saver: { quality: 50 }
    )
  end

  private

  # Валидация длины текста
  def content_length
    return if content.nil?
    plain_text = content.to_plain_text.strip
    if plain_text.blank?
      errors.add(:content, "должен содержать текст")
    elsif plain_text.length < 10
      errors.add(:content, "слишком короткий (минимум 10 символов текста)")
    end
  end

  # Работает в основной транзакции сохранения
  def cache_text_data
    html = content.to_s
    # Заменяем теги блоков на пробелы, чтобы слова не слипались
    processed_html = html.gsub(/<\/(h[1-6]|p|div|li)>/, " </\\1>")

    full_plain_text = ActionController::Base.helpers.strip_tags(processed_html)
                                            .gsub(/\s+/, " ")
                                            .strip

    # Прямое присваивание атрибуту. Запишется вместе с постом.
    self.title = truncated_title_from(full_plain_text)
  end

  # Работает после записи в БД
  def cache_images_data
    # Ищем картинки в ActionText вложениях
    attachments = content.embeds.select(&:image?)
    new_preview_blob_id = attachments.first&.blob_id
    new_images_count = attachments.size

    # Если данные о картинках изменились — обновляем колонки без лишних коллбэков
    if images_count != new_images_count || preview_blob_id != new_preview_blob_id
      update_columns(
        images_count: new_images_count,
        preview_blob_id: new_preview_blob_id
      )

      # Сразу генерируем превью, чтобы оно лежало в кэше
      preview_variant&.processed if new_preview_blob_id
    end
  end

  # Обрезка заголовка
  def truncated_title_from(plain_text)
    return plain_text if plain_text.length <= Entry::TITLE_PREVIEW_LENGTH

    stop_at = plain_text[0..Entry::TITLE_PREVIEW_LENGTH].rindex(" ") || Entry::TITLE_PREVIEW_LENGTH
    "#{plain_text[0...stop_at].strip}..."
  end
end
