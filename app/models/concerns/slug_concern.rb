# frozen_string_literal: true

module SlugConcern
  extend ActiveSupport::Concern

  included do
    extend FriendlyId
    friendly_id :slug_candidates, use: :slugged, slug_limit: 70
    after_create :remake_slug

    def slug_candidates
      [
        :content,
        %i[content id]
      ]
    end

    # FRIENDLY_ID UNIQUE
    def remake_slug
      update_attribute(:slug, nil)
      save!
    end

    # def should_generate_new_friendly_id?
    #   new_record? || self.slug.nil?
    # end

    private

    # FRIENDLY_ID UPDATE
    def should_generate_new_friendly_id?
      slug.blank? || subtitle_changed? || title_changed?
    end
  end
end
