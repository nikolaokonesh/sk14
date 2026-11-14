class PostsController < ApplicationController
  allow_unauthenticated_access only: %i[ show ]
  before_action :set_district, only: [:new, :create]
  before_action :set_post, only: [:show, :edit, :update, :destroy]
  before_action :set_district_from_post, only: [:show, :edit, :update]
  before_action :authorize_post_owner!, only: [:edit, :update, :destroy]

  def new
    @post = @district.posts.new
  end

  def create
    @post = @district.posts.build(post_params.merge(user: current_user))
    
    plain_text = ActionText::Content.new(params[:post][:content]).to_plain_text
    parsed = PostParser.new(plain_text, @district).call

    @post.post_type = parsed[:post_type]
    @post.action_type = parsed[:action_type]
    @post.category = parsed[:category]

    if @post.save
      redirect_to @post, notice: "✅ Объявление успешно опубликовано!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @categories = Category.order(:position)
    # fresh_when(
    #   etag: [@post, @post.category, Category.maximum(:updated_at), current_user],
    #   last_modified: @post.updated_at
    # )
  end

  def edit
  end

  def update
    # Разрешаем любые из этих параметров, но не требуем их все сразу
    permitted = params.require(:post).permit(:content, :category_id, :action_type, :post_type)

    # 🆕 СЦЕНАРИЙ 1: Обновление только категории из модального окна
    if permitted[:category_id].present? && permitted[:content].blank?
      if @post.update(category_id: permitted[:category_id])
      else
        redirect_to @post, alert: "Ошибка при обновлении категории"
      end
    
    # 🆕 СЦЕНАРИЙ 2: Полное редактирование поста (через форму edit)
    else
      @post.assign_attributes(permitted)

      if @post.save
      else
        render :edit, status: :unprocessable_entity
      end
    end
  end

  def destroy
    district = @post.district
    @post.destroy
    redirect_to district_path(district.slug), notice: "🗑️ Пост удален."
  end

  private

  # 🆕 Надежный поиск улуса
  def set_district
    # Rails может передавать параметр под разными именами в зависимости от routes.rb
    district_param = params[:district_id] || params[:district_slug] || params[:slug]
    
    if district_param.present?
      # Ищем сначала по slug, потом по id
      @district = District.find_by(slug: district_param) || District.find_by(id: district_param)
    end
    
    # Если улус не найден, безопасно редиректим на главную
    unless @district
      redirect_to root_path, alert: "Улус не найден"
    end
  end

  def set_post
    @post = Post.find(params[:id])
  end

  def set_district_from_post
    @district = @post.district if @post
  end

  def authorize_post_owner!
    unless @post.user == current_user
      redirect_to @post, alert: "У вас нет прав для этого действия."
    end
  end

  def post_params
    params.expect(post: [ :content, :category_id, :action_type, :post_type ])
  end
end