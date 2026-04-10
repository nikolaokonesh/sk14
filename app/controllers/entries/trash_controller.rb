class Entries::TrashController < ApplicationController
  include CommentsLoader

  before_action :set_target_user, only: :index
  before_action :set_entry, only: %i[show update]
  def index
    authorize! :view_trash, @target_user

    @entries = @target_user.entries
                           .inactive
                           .includes(entryable: :entry)
                           .where(entryable_type: Entry::POST_TYPE)
                           .recent
    render Views::Entries::Index.new(
      entries: @entries
    )
  end

  def show
    unless @entry.trash?
      redirect_to entry_path(@entry), notice: "Пост не был удален"
      return
    end
    render Views::Entries::Show.new(
      entry: @entry
    )
  end

  def update
    authorize! :restore, @entry

    if @entry.update(trash: false, trash_data: nil)
      flash[:success] = "Успешное восстановление!"
      redirect_to @entry
    else
      redirect_to trash_path(@entry), alert: @entry.errors.full_messages.to_sentence
    end
  end

  private

  def set_target_user
    @target_user = params[:user_id].present? ? User.find(params[:user_id]) : Current.user
  end

  def set_entry
    @entry = Entry.includes(:user).find(params.expect(:id))

    authorize! :view_trash, @entry.user
  end
end
