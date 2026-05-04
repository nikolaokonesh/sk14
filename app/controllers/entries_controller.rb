class EntriesController < ApplicationController
  allow_unauthenticated_access only: %i[ index show ]
  before_action :set_entry, only: %i[ show edit update destroy ]

  def index
    # 1. Загружаем "корневые" объекты
    # Используем только базовые условия, чтобы БД отработала быстро
    @afishas = Post.afisha_active.to_a
    @top_advertisements = Advertisement.on_top.limit(20).to_a

    @entries_scope = Entry.active.posts.recent
    set_page_and_extract_portion_from @entries_scope
    @records = @page.records.to_a

    # 2. Собираем всё в один массив для массовой предзагрузки
    # Это ключевой момент: preloader объединит запросы к User и EntryRead
    all_entries = @records + @afishas.map(&:entry) + @top_advertisements.map(&:entry)
    all_entries.compact!

    # 3. Массовая загрузка ассоциаций через Preloader (Rails 7+ syntax)
    # Это уберет 3 запроса User Load и объединит их в 1
    preloader = ActiveRecord::Associations::Preloader.new
    preloader.preload(all_entries, [ :user, :entry_reads, :entryable ])

    # Для рекламы отдельно догружаем ActionText контент
    ad_entries = @top_advertisements.map(&:entry).compact
    preloader.preload(ad_entries, { rich_text_content: { embeds_attachments: :blob } })

    # 4. Собираем статусы прочтения (теперь данные уже в памяти, запросов к БД не будет)
    @read_entry_ids = if authenticated?
      current_user.entry_reads
                  .where(entry_id: all_entries.map(&:id).uniq)
                  .pluck(:entry_id)
                  .to_set
    else
      Set.new
    end

    render Views::Entries::Index.new(
      page: @page,
      records: @records,
      afishas: @afishas,
      top_advertisements: @top_advertisements,
      read_entry_ids: @read_entry_ids
    )
  end



  def show
    if turbo_frame_request_id == "read" && current_user
      Current.user.mark_entry_as_read!(@entry)
      # Передаем Set с одним ID для совместимости с новым компонентом
      render Components::Entries::ReadBadge.new(entry: @entry, read_entry_ids: Set.new([ @entry.id ])), layout: false
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
      @entry = Entry.find(params.expect(:id))
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
