Rails.application.routes.draw do
  resources :entries do
    resources :participants, only: :index, module: :entries
  end

  resources :advertisements, only: %i[index show create update destroy]

  resources :notifications, only: [ :index ] do
    member do
      patch :mark_as_read
    end
    collection do
      post :mark_all_as_read
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  namespace :auth do
    resource :sign, only: %i[show create destroy], controller: :sign
    resource :verification, only: %i[show create], controller: :verification
    resource :name, only: %i[show update], controller: :name
  end

  root "entries#index"
end
