# frozen_string_literal: true

module Entry::Content
  extend ActiveSupport::Concern

  included do
    has_rich_text :content

    validates :content, presence: true
    validate :content_length

    before_save :cache_text_data, if: -> { content.changed? }
    after_save_commit :cache_images_data
  end

  def preview_variant(width: 50, height: 50)
    return nil unless preview_blob_id

    preview_blob.variant(
      resize_to_fill: [ width, height ],
      format: :webp,
      saver: { quality: 50 }
    )
  end

  private

  def content_length
    return if content.nil?

    plain_text = content.to_plain_text.strip

    if plain_text.blank?
      errors.add(:content, "должен содержать текст")
    elsif plain_text.length < 10
      errors.add(:content, "слишком короткий (минимум 10 символов текста)")
    end
  end

  def cache_text_data
    self.title = truncated_title_from(content_plain_text)
  end

  def cache_images_data
    attachments = image_attachments
    new_preview_blob_id = attachments.first&.blob_id
    new_images_count = attachments.size

    return unless cached_image_data_changed?(new_images_count, new_preview_blob_id)

    update_cached_image_columns(new_images_count, new_preview_blob_id)
    process_preview_variant(new_preview_blob_id)
  end

  def content_plain_text
    ActionController::Base.helpers.strip_tags(html_with_block_spacing)
                                  .gsub(/\s+/, " ")
                                  .strip
  end

  def html_with_block_spacing
    content.to_s.gsub(%r{</(h[1-6]|p|div|li)>}, " </\\1>")
  end

  def image_attachments
    content.embeds.select(&:image?)
  end

  def cached_image_data_changed?(new_images_count, new_preview_blob_id)
    images_count != new_images_count || preview_blob_id != new_preview_blob_id
  end

  def update_cached_image_columns(new_images_count, new_preview_blob_id)
    update_columns(
      images_count: new_images_count,
      preview_blob_id: new_preview_blob_id
    )
  end

  def process_preview_variant(new_preview_blob_id)
    preview_variant&.processed if new_preview_blob_id
  end

  def truncated_title_from(plain_text)
    return plain_text if plain_text.length <= Entry::TITLE_PREVIEW_LENGTH

    stop_at = plain_text[0..Entry::TITLE_PREVIEW_LENGTH].rindex(" ") || Entry::TITLE_PREVIEW_LENGTH
    "#{plain_text[0...stop_at].strip}..."
  end
end
