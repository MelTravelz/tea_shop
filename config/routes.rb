Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  namespace :api do
    namespace :v1 do
      get '/merchants', to: 'merchants#index'
      get '/merchants/find', to: 'merchants/search#show'
      get '/merchants/:id', to: 'merchants#show'
      get '/merchants/:id/items', to: 'merchants/items#index'

      get '/items', to: 'items#index'
      post '/items', to: 'items#create'
      get '/items/:id', to: 'items#show'
      put '/items/:id', to: 'items#update'
      delete '/items/:id', to: 'items#destroy'
      get '/items/:id/merchant', to: 'items/merchants#show'
    end
  end
end
