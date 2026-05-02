# frozen_string_literal: true

module Entry::Threading
  extend ActiveSupport::Concern

  included do
    before_validation :set_root_from_parent, if: :parent_id?
    after_create :set_self_as_root, unless: :root_id?
    validate :root_consistency, on: :update, if: :root_id_changed?
  end

  private

  def set_root_from_parent
    self.root_id = parent.root_id
  end

  def set_self_as_root
    update_column(:root_id, id)
  end

  def root_consistency
    errors.add(:root_id, "cannot be changed once set root_id")
  end
end
