class EntriesController < ApplicationController
  allow_unauthenticated_access only: %i[ index show ]
  before_action :set_entry, only: %i[ show edit update destroy ]

  # GET /entries or /entries.json
  def index
    @entries = Entry.active
                    .includes([ entryable: [ :entry ] ])
                    .where(entryable_type: "Post")
                    .recent
    render Views::Entries::Index.new(entries: @entries)
  end

  def show
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
      flash[:success] = "Пост обновлён"
      redirect_to @entry, status: :see_other
    else
      @entry.entryable.reload if @entry.entryable.content.blank?
      render Views::Entries::Form.new(entry: @entry), status: :unprocessable_entity
    end
  end

  def destroy
    authorize! :destroy, @entry
    if can?(:hard_destroy, @entry) && current_user.has_role?(:admin) && @entry.user_id != current_user.id
      @entry.destroy!
      flash[:alert] = "Пост удалён навсегда"
      redirect_to root_path, status: :see_other
      return
    end

    if @entry.update(trash: true, trash_data: Time.current)
      flash[:alert] = "Пост перемещен в удаленные посты"
      respond_to do |format|
        format.html { redirect_to root_path, status: :see_other }
        format.turbo_stream { render Views::Entries::Streams::Destroy.new(entry: @entry, message: flash[:alert]), layout: false }
      end
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
      params.expect(entry: [ :entryable_type, entryable_attributes: [ :id, :content, :no_comments ] ])
    end
end
