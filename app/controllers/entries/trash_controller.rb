class Entries::TrashController < ApplicationController
  def index
    @entries = Current.user.entries.inactive.recent
    @pagy, @entries = pagy_countless(@entries)
    render Views::Users::Show.new(user: Current.user, entries: @entries, pagy: @pagy, params: params[:page])
  end

  def show
    set_entry
    if @entry.trash == true
      render Views::Entries::Show.new(entry: @entry)
    else
      redirect_to entry_path(@entry), notice: "Пост не был удален"
    end
  end

  def update
    set_entry
    @entry.trash = false
    @entry.save
    flash.now[:notice] = "Успешное восстановление!"
    Entries::Streams::RecoveryJob.perform_later(@entry.id)
    respond_to do |format|
      format.html { redirect_to @entry, notice: flash.now[:notice] }
      format.turbo_stream { render Views::Entries::Streams::Destroy.new(entry: @entry, message: flash.now[:notice]), layout: false }
    end
  end

  private

  def set_entry
    @entry = Current.user.entries.find(params.expect(:id))
  end
end
