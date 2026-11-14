class UsersController < ApplicationController
  allow_unauthenticated_access only: %i[show]

  before_action :set_user, only: %i[show update]
  before_action :require_owner!, only: %i[update]

  def show
    @posts_count = @user.posts.count

    posts = @user.posts.includes(:district, :category)
    set_page_and_extract_portion_from(posts, ordered_by: { published_at: :desc, id: :desc })

    @posts = @page.records

    # Передаём все зависимости в ETag
    # fresh_when(
    #   etag: [
    #     @user,                          # Изменилось имя или данные профиля
    #     @posts_count,                   # Добавили или удалили объявление
    #     @posts.maximum(:updated_at),    # Отредактировали одно из объявлений на странице
    #     params[:page],                  # Перешли на другую страницу пагинации
    #     current_user                    # Зашёл владелец профиля или гость
    #   ],
    #   last_modified: [@user.updated_at, @posts.maximum(:updated_at)].compact.max
    # )
  end

  def update
    if @user.update(user_params)
    else
    end
  end

  private

  def set_user
    @user = User.friendly.find(params[:slug])
  end

  def require_owner!
    unless authenticated? && current_user == @user
      redirect_to user_path(@user), alert: "Можно менять только своё имя"
    end
  end

  def user_params
    params.expect(user: [:name])
  end
end