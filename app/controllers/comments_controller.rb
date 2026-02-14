class CommentsController < ApplicationController
  allow_unauthenticated_access only: :index
  before_action :set_comment, only: %i[ edit update destroy cancel_edit ]
  before_action :set_entry

  def index
    @limit = 20
    ref_id = params[:ref_id].to_i || nil

    if request.headers["Turbo-Frame"].nil?
      return redirect_to entry_path(@entry.root, comment_id: params[:comment_id])
    end

    if params[:comment_id].present? && params[:direction].blank?
      # 1. Точка вохода из уведомления
      @target_comment = @entry.comments.find(params[:comment_id])
      @before_comments = @entry.comments.where("id < ?", @target_comment.id)
                              .order(id: :desc).limit(@limit).to_a.reverse
      @after_comments = @entry.comments.where("id > ?", @target_comment.id)
                              .order(id: :asc).limit(@limit).to_a

      @comments = @before_comments + [ @target_comment ] + @after_comments

      @pagy_has_prev = @before_comments.size >= @limit
      @pagy_has_next = @after_comments.size >= @limit

      @button_down = true
    elsif params[:direction] == "prev"
      # Scroll вверх (старые)
      scope = @entry.comments.where("id < ?", ref_id).order(id: :desc)
      @pagy, @comments = pagy_countless(scope, limit: @limit)
      @comments = @comments.reverse
    elsif params[:direction] == "next"
      # Scroll вниз (новые)
      scope = @entry.comments.where("id > ?", ref_id).order(id: :asc)
      @pagy, @comments = pagy_countless(scope, limit: @limit)
    else
      scope = @entry.comments.order(id: :asc)
      count = scope.count
      initial_page = count.zero? ? 1 : (count.fdiv(20)).ceil
      @pagy, @comments = pagy_countless(scope, limit: @limit, page: initial_page)
    end

    render Views::Comments::Index.new(entry: @entry,
                                      comments: @comments,
                                      pagy: @pagy,
                                      direction: params[:direction],
                                      highlight_id: params[:comment_id],
                                      frame_id: params[:frame_id],
                                      has_prev: @pagy_has_prev,
                                      has_next: @pagy_has_next,
                                      button_down: @button_down)
  end

  def edit
    render turbo_stream: [
      turbo_stream.replace("content_comment_#{@comment.id}", renderable: Components::Comments::Form::Edit.new(entry: @comment), layout: false),
      turbo_stream.update("dropdown_comment_hide_#{@comment.id}")
    ]
  end

  def cancel_edit
    render turbo_stream: turbo_stream.replace(@comment.entry, renderable: Components::Comments::Card.new(entry: @comment.entry, is_last_in_group: true) { |c| c.card_comment })
  end

  def update
    if @comment.update(comment_params)
      render turbo_stream: turbo_stream.replace(@comment.entry, renderable: Components::Comments::Card.new(entry: @comment.entry, is_last_in_group: true, highlight: true) { |c| c.card_comment })
    else
      @comment.reload if @comment.content.blank?
      respond_to do |format|
        format.turbo_stream {
          render turbo_stream: [
            turbo_stream.update("comment_content_chat_#{@comment.id}",
              renderable: Components::Comments::Form::Edit.new(entry: @comment), layout: false),
            turbo_stream.update("comment_edit_error_#{@comment.id}",
              renderable: Components::Comments::Error.new(entry: @comment.entry), layout: false)
          ]
        }
      end
    end
  end

  def destroy
    authorize! :destroy, @comment
    @comment.entry.destroy
    render turbo_stream: turbo_stream.remove(@comment.entry)
  end

  def create
    @comment = Comment.new(comment_params)

    parent = if params[:comment][:parent_id].present?
      parent = params[:comment][:parent_id].to_i
      parent = Entry.find_by_id(parent)
    else
      @entry.root
    end

    @comment.build_entry(user: Current.user, parent: parent)
    previous_comment = @entry.root.replies.where.not(id: @comment.entry.id).last

    if @comment.save
      respond_to do |format|
        format.turbo_stream { render Views::Comments::Streams::Create.new(entry: @comment.entry,
                                  previous_comment: previous_comment), layout: false }
        format.html { redirect_to post_path(@entry.root), notice: "Комментарий добавлен" }
      end
    else
      respond_to do |format|
        format.turbo_stream {
          render turbo_stream:
            turbo_stream.update("comment_create_error",
              renderable: Components::Comments::Error.new(entry: @comment.entry), layout: false), status: :unprocessable_entity
        }
      end
    end
  end

  private

  def set_entry
    @entry = Entry.find(params[:entry_id])
  end

  def set_comment
    @comment = Comment.find(params[:id])
  end

  def comment_params
    params.expect(comment: [ :content ])
  end
end
