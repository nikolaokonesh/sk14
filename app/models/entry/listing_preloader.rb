# frozen_string_literal: true

module Entry::ListingPreloader
  extend ActiveSupport::Concern

  class_methods do
    def load_for_list(scope, current_user = nil, use_recent: true)
      records = preload_listing_records(scope, use_recent: use_recent)

      mark_read_states(records, current_user) if current_user
      attach_preview_blobs(records)
      attach_inverse_entryable_records(records)

      records
    end

    def afisha_for_main(current_user = nil)
      load_for_list(afisha_for_main_scope, current_user, use_recent: false)
    end

    def ads_for_main(current_user = nil)
      load_for_list(ads_for_main_scope, current_user, use_recent: false)
    end

    private

    def preload_listing_records(scope, use_recent: true)
      relation = normalize_listing_scope(scope)
      relation = relation.recent if use_recent
      relation.includes(:user, :entryable).to_a
    end

    def normalize_listing_scope(scope)
      scope.is_a?(Array) ? where(id: scope) : scope
    end

    def mark_read_states(records, current_user)
      read_ids = current_user.read_entry_ids

      records.each do |entry|
        entry.read_by_user = read_ids.include?(read_target_id(entry))
      end
    end

    def read_target_id(entry)
      entry.root_id || entry.id
    end

    def attach_preview_blobs(records)
      blobs_by_id = preview_blobs_by_id(records)

      records.each do |entry|
        entry.instance_variable_set(
          :@preview_blobs_for_list,
          entry.preview_blob_ids.filter_map { |id| blobs_by_id[id] }
        )
      end
    end

    def preview_blobs_by_id(records)
      preview_blob_ids = records.flat_map(&:preview_blob_ids).uniq
      return {} if preview_blob_ids.empty?

      ActiveStorage::Blob.where(id: preview_blob_ids)
                         .includes(:variant_records)
                         .index_by(&:id)
    end

    def attach_inverse_entryable_records(records)
      records.each do |entry|
        entry.entryable.association(:entry).target = entry if entry&.entryable
      end
    end

    def afisha_for_main_scope
      active.joins("INNER JOIN posts ON entries.entryable_id = posts.id AND entries.entryable_type = 'Post'")
            .merge(Post.afisha_active)
            .reorder("posts.event_date ASC")
    end

    def ads_for_main_scope
      active.joins("INNER JOIN advertisements ON entries.entryable_id = advertisements.id AND entries.entryable_type = 'Advertisement'")
            .merge(Advertisement.on_top)
            .limit(20)
    end
  end
end
