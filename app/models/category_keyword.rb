class CategoryKeyword < ApplicationRecord
  belongs_to :category

  validates :word, presence: true
  validates :word, uniqueness: { scope: :category_id }

  def self.dictionary_hash
    Rails.cache.fetch("category_keywords_dict", expires_in: 7.days) do
      all.map { |kw| [kw.word.downcase, [kw.category_id, kw.weight]] }.to_h
    end
  end

  after_commit :clear_dictionary_cache

  private

  def clear_dictionary_cache
    Rails.cache.delete("category_keywords_dict")
  end
end