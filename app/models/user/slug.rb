# frozen_string_literal: true

module User::Slug
  extend ActiveSupport::Concern

  included do
    extend FriendlyId

    friendly_id :email_prefix, use: :slugged

    after_create :ensure_unique_slug_with_id
  end

  def email_prefix
    email.split("@").first if email.present?
  end

  private

  def ensure_unique_slug_with_id
    update_column(:slug, unique_slug_value)
  end

  def unique_slug_value
    email_prefix_already_taken? ? "#{email_prefix}-#{id}" : email_prefix
  end

  def email_prefix_already_taken?
    User.where("email LIKE ?", "#{email_prefix}@%").where.not(id: id).exists?
  end

  def should_generate_new_friendly_id?
    slug.blank?
  end
end
