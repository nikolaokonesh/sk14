class EntriesController < ApplicationController
  allow_unauthenticated_access only: %i[ index show ]
  before_action :set_entry, only: %i[ show edit update destroy ]

  def index
    # 1. Загружаем афиши
    @afishas = Post.afisha_active
                  .includes(:entry)
                  .order(Arel.sql("json_extract(setting, '$.event_date') ASC"))

    # 2. Получаем ID записей (entries), которые уже есть в афише
    afisha_entry_ids = @afishas.map(&:entry).compact.map(&:id)

    # 3. Исключаем их из основной ленты через .where.not
    scope = Entry.active.posts
    scope = scope.where.not(id: afisha_entry_ids) if afisha_entry_ids.any?

    set_page_and_extract_portion_from scope.includes(:user, :entry_reads, :entryable).recent

    Current.user.entry_reads.load if authenticated?

    render Views::Entries::Index.new(page: @page, afishas: @afishas)
  end

  def show
    if turbo_frame_request_id == "read" && current_user
      Current.user.mark_entry_as_read!(@entry)
      render Components::Entries::ReadBadge.new(entry: @entry, user: Current.user), layout: false
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
    # Use callbacks to share common setup or constraints between actions.
    def set_entry
      @entry = Entry.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def entry_params
      params.expect(entry: [
        :content, :entryable_type, entryable_attributes: [
          :id, :no_comments, :duration, :is_afisha, :event_date, :event_duration,
          :urgent, :important, :event, :question, :sell, :buy, :help
        ]
      ])
    end
end
