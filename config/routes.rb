Rails.application.routes.draw do
  resources :entries do
    resources :comments, only: %i[index create edit update destroy] do
      member do
        get :cancel_edit
      end
    end
    resources :participants, only: :index, module: :entries
    collection do
      resources :trash, only: %i[index show update], module: :entries
    end
    resources :reactions, only: [] do
      post :toggle, on: :collection
    end
  end

  resources :tags, only: %i[index show]

  resources :subscriptions, only: [ :create, :destroy ]

  resources :notifications, only: [ :index ] do
    collection do
       post :mark_all_as_read
    end
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  resource :auth, only: %i[show create destroy], controller: :auth
  resource :auth_verification, only: %i[show create], controller: :auth_verification

  resources :users, except: %i[index new]
  namespace :user do
    resources :name, only: %i[index update]
    resources :avatars, except: :index
    resources :feeds, only: :index
  end

  # Defines the root path route ("/")
  root "entries#index"
end
