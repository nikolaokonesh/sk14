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

    respond_to do |format|
      format.json { render json: { ok: true } }
      format.turbo_stream { head :no_content }
      format.html { redirect_back fallback_location: root_path }
    end

  rescue StandardError => e
    Rails.logger.error("[ReactionsController#toggle] #{e.class}: #{e.message}")
    respond_to do |format|
      format.json { render json: { ok: true, warning: e.message } }
      format.turbo_stream { head :ok }
      format.html { redirect_back fallback_location: root_path, alert: "Не удалось поставить реакцию" }
    end
  end
end
