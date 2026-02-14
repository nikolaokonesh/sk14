module User::Slug
  extend ActiveSupport::Concern

  included do
    extend FriendlyId
    friendly_id :slug_candidates, use: :slugged

    def slug_candidates
      [
        email.split("@").first,
        [ email.split("@").first, :id ]
      ]
      # [
      #   :name,
      #   %i[name id]
      # ]
    end

    private

    # FRIENDLY_ID UPDATE
    def should_generate_new_friendly_id?
      slug.blank?
    end
  end
end
