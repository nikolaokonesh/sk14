class User::FeedsController < ApplicationController
  before_action :set_user, only: :index
  def index
    # Посты пользователей, на которых подписан
    user_ids = @user.followed_user_ids
    tag_ids = @user.followed_tag_ids

    @entries = Entry.active
                    .includes(user: { avatar: { avatar_attachment: :blob } }, entryable: :entry)
                    .left_outer_joins(:tags)
                    .where("entries.user_id IN (?) OR tags.id IN (?)", user_ids, tag_ids)
                    .where(entryable_type: "Post")
                    .where.not(user_id: @user.id)
                    .distinct
                    .order(created_at: :desc)
    @pagy, @entries = pagy_countless(@entries)
    render Views::Users::Show.new(user: @user, entries: @entries, pagy: @pagy, params: params[:page])
  end

  private

  def set_user
    @user = Current.user
  end
end
