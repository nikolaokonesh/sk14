module SearchLoader
  extend ActiveSupport::Concern

  private

  def apply_query_search
    # поле поиска и вывод найденного
    if @query.present?
      keywords = @query.to_s.downcase.scan(/[а-яёa-z0-9]+/i)
      stems = keywords.map { |w| RussianStemmer.stem(w) }.reject(&:blank?).uniq
      if stems.any?
        stems.each do |stem|
          @entries = @entries.where(
            "LOWER(entries.title) LIKE :s OR LOWER(COALESCE(entries.tags_list, '')) LIKE :s",
            s: "%#{stem}%")
        end
      end
    end
  end

  def load_tags_for_search
    # тэги поиска на главной странице
    categories = ListingsDictionary::ACTIONS.keys
    counts_hash = Tag.where(name: categories)
                 .joins(:entries)
                 .merge(Entry.active.where(entryable_type: "Post"))
                 .group(:name)
                 .count

    sorted_counts = counts_hash.sort_by { |_name, count| -count }.reject { |_name, count| count.zero? }

    @visible_categories = sorted_counts.map(&:first)

    @counts = counts_hash
    @all_posts_count = Entry.active.where(entryable_type: "Post").count
  end
end
