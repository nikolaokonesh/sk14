class EntriesController < ApplicationController
  allow_unauthenticated_access only: %i[ index show ]
  before_action :set_entry, only: %i[ show edit update destroy ]

def index
  # 1. Быстрые запросы только за ID
  afisha_ids = Entry.active.joins(:post)
                    .merge(Post.afisha_active)
                    .reorder("posts.event_date ASC")
                    .pluck(:id)

  ads_ids    = Entry.active.joins(:advertisement)
                    .merge(Advertisement.on_top)
                    .limit(20)
                    .pluck(:id)

  # Пагинация ленты
  set_page_and_extract_portion_from Entry.active.posts.recent
  recent_ids = @page.records.pluck(:id)

  # 2. Пакетная загрузка всех данных
  all_ids = (afisha_ids + ads_ids + recent_ids).uniq
  all_records = Entry.load_for_list(all_ids, current_user, use_recent: false)
  indexed_records = all_records.index_by(&:id)

  # 3. БЕЗОПАСНОЕ распределение с фильтрацией типов
  # Это гарантирует, что в афишу попадут ТОЛЬКО посты
  @afisha_entries = afisha_ids.map { |id| indexed_records[id] }
                             .compact
                             .select { |e| e.post? }

  @ad_entries     = ads_ids.map { |id| indexed_records[id] }
                           .compact
                           .select { |e| e.advertisement? }

  @records        = recent_ids.map { |id| indexed_records[id] }
                              .compact
                              .select { |e| e.post? }

  @read_entry_ids = authenticated? ? current_user.read_entry_ids : Set.new

  render Views::Entries::Index.new(
    page: @page,
    records: @records,
    afishas: @afisha_entries.map(&:entryable).compact,
    top_advertisements: @ad_entries.map(&:entryable).compact,
    read_entry_ids: @read_entry_ids
  )
end



  def show
    if turbo_frame_request_id == "read" && authenticated?
      current_user.mark_entry_as_read!(@entry) # Бродкаст уйдет из модели автоматически
      # Возвращаем badge (хотя стрим его тоже заменит, лучше вернуть для надежности)
      render Components::Entries::ReadBadge.new(entry: @entry, user: current_user), layout: false
      return
    end
    render Views::Entries::Show.new(entry: @entry)
  end

  def new
    @entry = Current.user.entries.new(entryable: Post.new)
    render Views::Entries::Form.new(entry: @entry)
  end

  def edit
    authorize! :edit, @entry
    render Views::Entries::Form.new(entry: @entry)
  end

  def create
    @entry = Current.user.entries.new(entry_params)

    if @entry.save
      Entries::Streams::CreateJob.perform_later(@entry.id)

      flash[:success] = "Пост успешно создан"
      respond_to do |format|
        format.html { redirect_to @entry }
      end
    else
      render Views::Entries::Form.new(entry: @entry), status: :unprocessable_entity
    end
  end

  def update
    authorize! :update, @entry
    if @entry.update(entry_params)
      Entries::Streams::UpdateJob.perform_later(@entry.id)

      flash[:success] = "Пост обновлён"
      redirect_to @entry, status: :see_other
    else
      render Views::Entries::Form.new(entry: @entry), status: :unprocessable_entity
    end
  end

  def destroy
    authorize! :destroy, @entry
    if can?(:hard_destroy, @entry) && current_user.has_role?(:admin) && @entry.user_id != current_user.id
      @entry.destroy!
      Entries::Streams::DestroyJob.perform_later(nil)
      flash[:alert] = "Пост удалён навсегда"
      redirect_to root_path, status: :see_other
      return
    end

    if @entry.update(trash: true, trash_data: Time.current)
      Entries::Streams::DestroyJob.perform_later(@entry.id)
      flash[:alert] = "Пост перемещен в удаленные посты"
      redirect_to root_path, status: :see_other
    else
      redirect_to @entry, alert: @entry.errors.full_messages.to_sentence
    end
  end

  private

    def preload_current_user_read_states
      root_entry_ids = @page.records.map { |entry| entry.root_id || entry.id }.uniq
      return if root_entry_ids.empty?

      Current.user.entry_reads.where(entry_id: root_entry_ids).load
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_entry
      @entry = Entry.includes(
        :entryable,
        user: :roles, # Чтобы can?(:manage, @entry) не лез в базу за ролями автора
        rich_text_content: {
          embeds_attachments: {
            blob: :variant_records # Добавляем это, если используете миниатюры
          }
        }
      ).find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def entry_params
      params.expect(entry: [
        :content, :entryable_type, entryable_attributes: [
          :id, :no_comments, :duration, :is_afisha, :event_date, :event_duration, :manual_finished, :finished_at,
          :urgent, :important, :event, :question, :sell, :buy, :help
        ]
      ])
    end
end
