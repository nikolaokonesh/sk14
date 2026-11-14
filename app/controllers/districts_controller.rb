class DistrictsController < ApplicationController
  allow_unauthenticated_access

  def index
    @districts = District.arctic.order(:position).includes(:posts)
  end

  def show
    @district = District.find_by!(slug: params[:slug])

    # 1. Данные для вида "По категориям"
    @categories = Category.joins(:posts)
      .where(posts: { district: @district })
      .where.not(posts: { category_id: nil })
      .distinct
      .order(:position)

    @posts_by_category = {}
    @categories.each do |category|
      posts = @district.posts.where(category: category)
      set_page_and_extract_portion_from(posts, ordered_by: { published_at: :desc, id: :desc })
      
      @posts_by_category[category.id] = {
        records: @page.records,
        page: @page,
        category: category
      }
    end

    # 2. 🆕 Данные для вида "Лента" (ОБЯЗАТЕЛЬНО!)
    linear_posts = @district.posts
    set_page_and_extract_portion_from(linear_posts, ordered_by: { published_at: :desc, id: :desc })
    
    @linear_initial_posts = @page.records
    @linear_next_page = @page.last? ? nil : @page.next_param
  end

  # 🆕 Экшен для пагинации линейной ленты
  def linear_feed_paginate
    # ✅ Правильное имя параметра для вложенного маршрута
    @district = District.find_by!(slug: params[:district_slug])
    posts = @district.posts
    
    set_page_and_extract_portion_from(posts, ordered_by: { published_at: :desc, id: :desc })
    
    @posts = @page.records
    @next_page = @page.last? ? nil : @page.next_param

    respond_to do |format|
      format.turbo_stream
    end
  end

  def category_posts
    @district = District.find_by!(slug: params[:district_slug])
    @category = Category.find_by!(slug: params[:category_slug])

    posts = @district.posts.where(category: @category)

    set_page_and_extract_portion_from(posts, ordered_by: { published_at: :desc, id: :desc })

    @posts = @page.records
    @next_page = @page.last? ? nil : @page.next_param

    respond_to do |format|
      format.turbo_stream
    end
  end
end