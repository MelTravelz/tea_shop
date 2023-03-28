Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  namespace :api do
    namespace :v1 do
      # resources :merchants, only: [:index, :show]
      get '/merchants', to: 'merchants#index'
      get '/merchants/:id', to: 'merchants#show'

      get '/items', to: 'items#index'
      post '/items', to: 'items#create'
      get '/items/:id', to: 'items#show'
      delete '/items/:id', to: 'items#destroy'
    end
  end

end
