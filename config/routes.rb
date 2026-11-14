Rails.application.routes.draw do
  namespace :auth do
    resource :sign, only: %i[show create destroy], controller: :sign
    resource :verification, only: %i[show create], controller: :verification
    resource :name, only: %i[show update], controller: :name
  end

  get "up" => "rails/health#show", as: :rails_health_check

  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  get "/districts", to: redirect("/")
resources :users, only: %i[show update], param: :slug, path: "u"
  get "/:slug", to: "districts#show", as: :district
  resources :districts, param: :slug, only: [:index, :show] do
    resources :posts, only: [:new, :create]
    get "categories/:category_slug/posts", to: "districts#category_posts", as: :category_posts
    get "linear_feed", to: "districts#linear_feed_paginate", as: :linear_feed_paginate
  end
  resources :posts, only: [:show, :edit, :update, :destroy]

  root "districts#index"
end
