# app/models/entry/listing_preloader.rb
module Entry::ListingPreloader
  extend ActiveSupport::Concern

  class_methods do
    # Универсальный метод
    def load_for_list(scope, current_user = nil)
      scope = where(id: scope) if scope.is_a?(Array)

      # Важно: добавляем .recent, если он не был передан в scope
      res = scope.recent.includes(:user, :entryable, :preview_blob)

      if current_user
        res = res.joins("LEFT JOIN entry_reads ON entry_reads.entry_id = entries.id AND entry_reads.user_id = #{current_user.id}")
                 .select("entries.*, (entry_reads.id IS NOT NULL) AS read_by_user")
      end

      res.to_a.tap do |records|
        records.each { |e| e.entryable.association(:entry).target = e if e&.entryable }
      end
    end

    def afisha_for_main
      load_for_list(
        active.joins("INNER JOIN posts ON entries.entryable_id = posts.id AND entries.entryable_type = 'Post'")
              .merge(Post.afisha_active)
      )
    end

    def ads_for_main
      load_for_list(
        active.joins("INNER JOIN advertisements ON entries.entryable_id = advertisements.id AND entries.entryable_type = 'Advertisement'")
              .merge(Advertisement.on_top).limit(20)
      )
    end
  end
end
