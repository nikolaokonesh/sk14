class ReactionsController < ApplicationController
  def toggle
    @entry = Entry.find(params[:entry_id])
    emoji = params[:content]

    # Ищем ЛЮБУЮ реакцию этого юзера на этот пост
    existing = @entry.reactions.find_by(user: Current.user)

    if existing
      if existing.content == emoji
        existing.destroy # Повторный клик — удаляем
      else
        existing.update(content: emoji) # Другой смайл — меняем
      end
    else
      @entry.reactions.create(user: Current.user, content: emoji) # Первая реакция
    end

    head :no_content
  end
end
