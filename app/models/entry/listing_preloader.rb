# app/models/entry/listing_preloader.rb
module Entry::ListingPreloader
  extend ActiveSupport::Concern

  class_methods do
    def load_for_list(scope, current_user = nil, use_recent: true)
      scope = where(id: scope) if scope.is_a?(Array)
      res = scope
      res = res.recent if use_recent

      records = res.includes(:user, :entryable, preview_blob: :variant_records).to_a

      if current_user
        # Используем метод из модели User, который ты скидывал раньше.
        # Он ОДИН раз за HTTP-запрос сходит в Solid Cache, заберет массив
        # и превратит его в Set для мгновенного поиска.
        read_ids = current_user.read_entry_ids

        records.each do |e|
          target_id = e.root_id || e.id
          e.read_by_user = read_ids.include?(target_id)
        end
      end

      records.each { |e| e.entryable.association(:entry).target = e if e&.entryable }
      records
    end

    def afisha_for_main(current_user = nil)
      scope = active.joins("INNER JOIN posts ON entries.entryable_id = posts.id AND entries.entryable_type = 'Post'")
                    .merge(Post.afisha_active)
                    .reorder("posts.event_date ASC")

      # Выключаем use_recent, чтобы работала сортировка афиши
      load_for_list(scope, current_user, use_recent: false)
    end

    def ads_for_main(current_user = nil)
      scope = active.joins("INNER JOIN advertisements ON entries.entryable_id = advertisements.id AND entries.entryable_type = 'Advertisement'")
                    .merge(Advertisement.on_top)
                    .limit(20)

      # Выключаем use_recent, чтобы работала сортировка рекламы
      load_for_list(scope, current_user, use_recent: false)
    end
  end
end
