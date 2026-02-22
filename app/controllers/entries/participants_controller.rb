class Entries::ParticipantsController < ApplicationController
  def index
    @entry = Entry.find(params[:entry_id])
    # Собираем автора поста + всех кто оставил комментарий
    @users = @entry.participants.includes(avatar: { avatar_attachment: :blob })

    render Components::Entries::Participants.new(users: @users), layout: false
  end
end
