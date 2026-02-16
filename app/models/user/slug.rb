module User::Slug
  extend ActiveSupport::Concern

  included do
    extend FriendlyId
    friendly_id :email_prefix, use: :slugged

    def email_prefix
      email.split("@").first if email.present?
    end

    after_create :ensure_unique_slug_with_id

    private

    def ensure_unique_slug_with_id
      other_users = User.where("email LIKE ?", "#{email_prefix}@%").where.not(id: id).exists?

      if other_users
        new_slug = "#{email_prefix}-#{id}"
        update_column(:slug, new_slug)
      else
        update_column(:slug, email_prefix)
      end
    end

    # FRIENDLY_ID UPDATE
    def should_generate_new_friendly_id?
      slug.blank?
    end
  end
end
