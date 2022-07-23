Rails.application.routes.draw do
  resources :posts
  get '/profile', to: 'account#show'
  put '/profile', to: 'account#update'

  post '/signup', to: 'auth#signup'
end
