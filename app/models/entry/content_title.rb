module Entry::ContentTitle
  extend ActiveSupport::Concern

  included do
    after_commit :enqueue_keyword_extraction, on: [ :create, :update ]
    after_save :update_truncated_content, if: :should_update_truncated_content?
  end

  private

  def should_update_truncated_content?
    post? && (saved_change_to_entryable_type? || saved_change_to_entryable_id? || saved_change_to_updated_at?)
  end

  def update_truncated_content
    return if entryable_content.blank?

    plain_text = normalized_plain_text_content
    truncated = truncated_title_from(plain_text)

    update_column(:title, truncated)
  end

  def enqueue_keyword_extraction
    return unless post? && active?
    ExtractEntryKeywordsJob.perform_later(self.id)
  end

  def post?
    entryable_type == Entry::POST_TYPE
  end

  def active?
    !trash
  end

  def entryable_content
    entryable&.content
  end

  def normalized_plain_text_content
    return entryable_content.to_plain_text if entryable_content.respond_to?(:to_plain_text)

    ActionController::Base.helpers.string_tags(entryable_content.to_s).squish
  end

  def truncated_title_from(plain_text)
    return plain_text if plain_text.length <= Entry::TITLE_PREVIEW_LENGTH

    space_index = plain_text[0..Entry::TITLE_PREVIEW_LENGTH].rindex(" ") || Entry::TITLE_PREVIEW_LENGTH
    "#{plain_text[0..space_index]}..."
  end
end
