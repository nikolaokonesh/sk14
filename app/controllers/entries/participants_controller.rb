class Entries::ParticipantsController < ApplicationController
  def index
    @entry = Entry.find(params[:entry_id])
    # Собираем автора поста + всех кто оставил комментарий
    @users = @entry.participants

    render Components::Entries::Participants.new(users: @users), layout: false
  end
end
