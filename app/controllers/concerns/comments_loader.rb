module CommentsLoader
  extend ActiveSupport::Concern

  private

  def load_comments_for(entry)
    limit = 20
    ref_id = params[:ref_id].to_i
    direction = params[:direction]
    comment_id = params[:comment_id]

    if comment_id.present? && direction.blank?
      # 1. Точка вохода из уведомления
      target_comment = entry.comments.find(comment_id)
      before = entry.comments.where("id < ?", target_comment.id)
                              .order(id: :desc).limit(limit).to_a.reverse
      after = entry.comments.where("id > ?", target_comment.id)
                              .order(id: :asc).limit(limit).to_a

      @comments = before + [ target_comment ] + after

      @has_prev = before.size >= limit
      @has_next = after.size >= limit

      @button_down = true
    elsif direction == "prev"
      # Scroll вверх (старые)
      scope = entry.comments.where("id < ?", ref_id).order(id: :desc)
      @pagy, @comments = pagy_countless(scope, limit: limit)
      @comments = @comments.reverse
      @has_prev = @pagy.next.present?
    elsif direction == "next"
      # Scroll вниз (новые)
      scope = entry.comments.where("id > ?", ref_id).order(id: :asc)
      @pagy, @comments = pagy_countless(scope, limit: limit)
      @has_next = @pagy.next.present?
    else
      scope = entry.comments.order(id: :asc)
      count = scope.count
      initial_page = count.zero? ? 1 : (count.fdiv(limit)).ceil
      @pagy, @comments = pagy_countless(scope, limit: limit, page: initial_page)
      @has_next = @pagy.next.present?
    end
  end
end
