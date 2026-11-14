class ClassifierKeyword < ApplicationRecord
  KINDS = %w[post_type action_type].freeze

  validates :kind, inclusion: { in: KINDS }
  validates :value, presence: true
  validates :word, presence: true
  validates :word, uniqueness: { scope: [:kind, :value] }

  def self.dictionary_for(kind)
    Rails.cache.fetch("classifier_keywords_#{kind}", expires_in: 7.days) do
      where(kind: kind).map { |ck| [ck.word.downcase, [ck.value, ck.weight]] }.to_h
    end
  end

  after_commit :clear_classifier_cache

  private

  def clear_classifier_cache
    Rails.cache.delete("classifier_keywords_post_type")
    Rails.cache.delete("classifier_keywords_action_type")
  end
end