# ==> app/jobs/extract_entry_keywords_job.rb <==
require_relative "../../lib/russian_stemmer"
class ExtractEntryKeywordsJob < ApplicationJob
  queue_as :default

  def perform(entry_id)
    entry = Entry.find_by(id: entry_id)
    return unless entry&.content&.body

    keywords = KeywordExtractor.call(entry.content.body.to_plain_text)

    ActiveRecord::Base.transaction do
      entry.entry_keywords.delete_all

      tag_data = keywords.map do |name|
        tag = Tag.find_or_create_by!(name: name)
        {
          entry_id: entry.id,
          tag_id: tag.id,
          keyword: name,
          frequency: 1,
          created_at: Time.current,
          updated_at: Time.current
        }
      end

      EntryKeyword.insert_all(tag_data) if tag_data.any?
    end

    entry.update_column(:tags_list, keywords.join(" "))
    Entries::NotifyFollowedTagsJob.perform_later(entry.id)
  end
end
