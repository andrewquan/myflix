Myflix::Application.routes.draw do
  root to: 'pages#front'
  get 'ui(/:action)', controller: 'ui'
  get '/home', to: 'videos#index'

  get '/register', to: 'users#new'

  get '/sign_in', to: 'sessions#new'
  post '/sign_in', to: 'sessions#create'
  get '/sign_out', to: 'sessions#destroy'

  resources :queue_items, only: [:create, :destroy]
  get '/my_queue', to: 'queue_items#index'
  post '/update_queue', to: 'queue_items#update_queue'

  resources :videos, only: [:show] do
    collection do
      post :search, to: 'videos#search'
    end
    resources :reviews, only: [:create]
  end

  resources :categories, only: [:show]
  resources :users, only: [:create, :show]
  delete '/unfollow', to: 'users#unfollow'
  resources :relationships, only: [:create, :destroy]
  get '/people', to: 'relationships#index'

  get '/forgot_password', to: 'forgot_passwords#new'
  resources :forgot_passwords, only: [:create]
  get '/forgot_password_confirmation', to: 'forgot_passwords#confirm'

  resources :password_resets, only: [:show, :create]
  get '/expired_token', to: 'password_resets#expired_token'
end
