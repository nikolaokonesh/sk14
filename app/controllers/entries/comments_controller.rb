# frozen_string_literal: true

class Entries::CommentsController < ApplicationController
  COMMENTS_PER_PAGE = 15

  before_action :require_authentication, only: %i[create destroy]
  before_action :set_root_entry

  def index
    set_page_and_extract_portion_from Entry.comments_for(@root_entry), per_page: COMMENTS_PER_PAGE

    render Components::Comments::Page.new(entry: @root_entry, page: @page), layout: false
  end

  def create
    authorize! :create, Entry
    return redirect_to_entry("Комментарии отключены") if @root_entry.entryable.no_comments?

    @comment_entry = Current.user.entries.new(comment_params)
    @comment_entry.parent = @root_entry
    @comment_entry.root = @root_entry
    @comment_entry.entryable = Comment.new

    if @comment_entry.save
      respond_to do |format|
        format.turbo_stream { render_create_turbo_stream }
        format.html { redirect_to_entry("Комментарий добавлен") }
      end
    else
      redirect_to_entry(@comment_entry.errors.full_messages.to_sentence, :alert)
    end
  end

  def destroy
    @comment_entry = Entry.comments_for(@root_entry).find(params.expect(:id))
    authorize! :destroy, @comment_entry
    @comment_entry.destroy!

    respond_to do |format|
      format.turbo_stream { render_destroy_turbo_stream }
      format.html { redirect_to_entry("Комментарий удалён") }
    end
  end

  private

    def require_authentication
      redirect_to auth_sign_path, alert: "Нужно войти в аккаунт" unless authenticated?
    end

    def set_root_entry
      @root_entry = Entry.find(params.expect(:entry_id))
    end

    def comment_params
      params.expect(entry: [ :content ])
    end

    def render_create_turbo_stream
      render turbo_stream: [
        turbo_stream.append(
          helpers.dom_id(@root_entry, :comments),
          Components::Comments::Message.new(entry: @comment_entry, root_entry: @root_entry)
        ),
        turbo_stream.replace(
          helpers.dom_id(@root_entry, :comment_form),
          Components::Comments::Form.new(entry: @root_entry)
        )
      ]
    end

    def render_destroy_turbo_stream
      render turbo_stream: turbo_stream.remove(helpers.dom_id(@comment_entry))
    end

    def redirect_to_entry(message, type = :notice)
      redirect_to polymorphic_path(@root_entry.entryable), type => message
    end
end
