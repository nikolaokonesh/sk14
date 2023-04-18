Rails.application.routes.draw do
  resources :lm_channels
  resources :lm_channel_values
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "lm_channels#index"
end
