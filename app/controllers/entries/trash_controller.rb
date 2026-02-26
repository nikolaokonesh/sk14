class Entries::TrashController < ApplicationController
  include CommentsLoader # load_comments_for()
  def index
    @entries = Current.user.entries
                           .inactive
                           .includes(user: { avatar: { avatar_attachment: :blob } }, entryable: :entry)
                           .recent

    @pagy, @entries = pagy_countless(@entries)
    render Views::Users::Show.new(
      user: Current.user, 
      entries: @entries, 
      pagy: @pagy, 
      params: params[:page]
    )
  end

  def show
    set_entry
    if @entry.trash?
      load_comments_for(@entry)
      render Views::Entries::Show.new(
        entry: @entry,
        direction: params[:direction],
        highlight_id: params[:comment_id],
        frame_id: params[:frame_id],
        comments: @comments,
        pagy: @pagy,
        has_prev: @has_prev,
        has_next: @has_next,
        button_down: @button_down
      )
    else
      redirect_to entry_path(@entry), notice: "Пост не был удален"
    end
  end

  def update
    set_entry
    if @entry.update(trash: false)
      flash[:success] = "Успешное восстановление!"
      Entries::Streams::RecoveryJob.perform_later(@entry.id)
      respond_to do |format|
        format.html { redirect_to @entry }
        format.turbo_stream { render Views::Entries::Streams::Destroy.new(entry: @entry, message: flash[:success]), layout: false }
      end
    else
      redirect_to trash_path(@entry), alert: @entry.errors.full_messages.to_sentence
    end
  end

  private

  def set_entry
    @entry = Current.user.entries.find(params.expect(:id))
  end
end
