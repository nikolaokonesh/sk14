class CommentsController < ApplicationController
  allow_unauthenticated_access only: :index
  before_action :set_comment, only: %i[ edit update destroy cancel_edit ]
  before_action :set_entry

  include CommentsLoader

  def index
    return redirect_to entry_path(@entry.root, comment_id: params[:comment_id]) if request.headers["Turbo-Frame"].nil?

    load_comments_for(@entry)

    render Views::Comments::Index.new(
      entry: @entry,
      comments: @comments,
      pagy: @pagy,
      direction: params[:direction],
      highlight_id: params[:comment_id],
      frame_id: params[:frame_id],
      has_prev: @has_prev || false,
      has_next: @has_next || false,
      button_down: @button_down
    ), layout: false
  end

  def edit
    render turbo_stream: [
      turbo_stream.replace("content_comment_#{@comment.id}", renderable: Components::Comments::Form::Edit.new(entry: @comment), layout: false),
      turbo_stream.update("dropdown_comment_hide_#{@comment.id}")
    ]
  end

  def cancel_edit
    render turbo_stream: turbo_stream.replace(@comment.entry, renderable: Components::Comments::Card.new(entry: @comment.entry) { |c| c.card_comment })
  end

  def update
    if @comment.update(comment_params)
      render turbo_stream: turbo_stream.replace(@comment.entry, renderable: Components::Comments::Card.new(entry: @comment.entry, highlight: true) { |c| c.card_comment })
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

    if @comment.save
      respond_to do |format|
        format.turbo_stream { render Views::Comments::Streams::Create.new(entry: @comment.entry), layout: false }
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
