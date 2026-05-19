# frozen_string_literal: true

class Entry < ApplicationRecord
  POST_TYPE = "Post".freeze
  ADVERTISEMENT_TYPE = "Advertisement".freeze
  COMMENT_TYPE = "Comment".freeze
  TITLE_PREVIEW_LENGTH = 500
  PREVIEW_IMAGES_LIMIT = 4

  broadcasts_refreshes

  include Content
  include ListingPreloader # Подгружает для EntriesController#index
  include Threading
  include Comments

  attr_accessor :read_by_user

  delegated_type :entryable, types: [POST_TYPE, ADVERTISEMENT_TYPE, COMMENT_TYPE], dependent: :destroy
  accepts_nested_attributes_for :entryable

  delegate :urgent, :important, :event, :question, :sell, :buy, :help, to: :entryable, allow_nil: true
  delegate :is_afisha?, :afisha_status, :event_date, :theme_gradient, :no_comments?, to: :entryable, allow_nil: true

  scope :recent, -> { order(created_at: :desc) }
  scope :active, -> { where(trash: false) }
  scope :inactive, -> { where(trash: true) }
  scope :roots, -> { where(parent_id: nil) }
  scope :comments, -> { where(entryable_type: COMMENT_TYPE) }

  belongs_to :user, touch: true
  belongs_to :parent, class_name: "Entry", optional: true
  belongs_to :root, class_name: "Entry", optional: true

  belongs_to :post, foreign_key: :entryable_id, optional: true
  belongs_to :advertisement, foreign_key: :entryable_id, optional: true
  attribute :preview_blob_ids, default: -> { [] }

  has_many :replies, class_name: "Entry", foreign_key: :parent_id
  has_many :descendants, class_name: "Entry", foreign_key: :root_id
  has_many :noticed_events, as: :record, class_name: "Noticed::Event", dependent: :destroy
  has_many :notifications, through: :noticed_events, class_name: "Noticed::Notification", dependent: :destroy
  has_many :entry_reads, dependent: :destroy

  def read_by_user?
    !!read_by_user
  end

  def participants
    participant_users_scope.distinct
  end

  def title
    self[:title].presence || "Без заголовка"
  end

  def images_count
    self[:images_count] || 0
  end

  def preview_blob_ids
    Array(self[:preview_blob_ids]).filter_map do |id|
      id.to_i if id.present?
    end
  end

  def preview_blobs_for_list
    if defined?(@preview_blobs_for_list)
      @preview_blobs_for_list
    else
      blobs_by_id = preview_blobs_by_cached_id
      preview_blob_ids.filter_map { |id| blobs_by_id[id] }
    end
  end

  def preview_blob
    preview_blobs_for_list.first
  end

  def preview_thumbnail_variant(blob, width: 48, height: 48)
    blob.variant(
      resize_to_fill: [ width, height ],
      format: :webp,
      saver: { quality: 50 }
    )
  end

  private

  def preview_blobs_by_cached_id
    return {} if preview_blob_ids.empty?

    ActiveStorage::Blob.where(id: preview_blob_ids)
                       .includes(:variant_records)
                       .index_by(&:id)
  end

  def participant_users_scope
    User.where(id: descendants.select(:user_id)).or(User.where(id: user_id))
  end

  def active?
    !trash
  end
end
