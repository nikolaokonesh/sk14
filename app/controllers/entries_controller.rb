class EntriesController < ApplicationController
  allow_unauthenticated_access only: %i[ index show ]
  before_action :set_entry, only: %i[ show edit update destroy ]

  def index
    # Ищем только активные посты через Entry
    @entries = Entry.active.includes([ :user, entryable: [ :entry ] ]).where(entryable_type: "Post").recent

    # Живой поиск
    if params[:query].present?
      keywords = params[:query].to_s.downcase.scan(/[а-яёa-z0-9]+/i)
      stems = keywords.map { |w| RussianStemmer.stem(w) }.uniq
      @entries = @entries.joins("JOIN posts ON entries.entryable_id = posts.id")
      stems.each do |stem|
        @entries = @entries.where("posts.title LIKE :s OR entries.tags_list LIKE :s", s: "%#{stem}%")
      end
    end

    @pagy, @entries = pagy_countless(@entries)
    render Views::Entries::Index.new(entries: @entries, pagy: @pagy, params: params[:page], query: params[:query])
  end

  def show
    if @entry.trash == true
      redirect_to root_path, notice: "Пост был удалён..."
    else
      render Views::Entries::Show.new(entry: @entry, params_comment_id: params[:comment_id])
    end
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

    # @entry.build_entry(user: Current.user)

    if @entry.save
      Entries::Streams::CreateJob.perform_later(@entry.id)
      flash.now[:success] = "Пост успешно создан"
      respond_to do |format|
        format.html { redirect_to @entry }
        format.turbo_stream { render Views::Entries::Streams::Create.new(entry: @entry, message: flash.now[:success]), layout: false }
      end
    else
      render Views::Entries::Form.new(entry: @entry), status: :unprocessable_entity
    end
  end

  def update
    authorize! :update, @entry
    if @entry.update(entry_params)
      Entries::Streams::UpdateJob.perform_later(@entry.id)
      flash.now[:success] = "Пост успешно обновлён"
      respond_to do |format|
        format.html { redirect_to @entry, status: :see_other }
        format.turbo_stream { render Views::Entries::Streams::Update.new(entry: @entry, message: flash.now[:success]), layout: false }
      end
    else
      @entry.entryable.reload if @entry.entryable.content.blank?
      render Views::Entries::Form.new(entry: @entry), status: :unprocessable_entity
    end
  end

  def destroy
    authorize! :destroy, @entry
    @entry.trash = true
    @entry.save
    Entries::Streams::DestroyJob.perform_later(@entry.id)
    flash.now[:notice] = "Пост перемещен в удаленные посты"
    respond_to do |format|
      format.html { redirect_to trash_path(@entry), status: :see_other }
      format.turbo_stream { render Views::Entries::Streams::Destroy.new(entry: @entry, message: flash.now[:notice]), layout: false }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_entry
      @entry = Entry.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def entry_params
      params.expect(entry: [ :entryable_type, entryable_attributes: [ :id, :content ] ])
    end
end
