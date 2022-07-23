Rails.application.routes.draw do
  resources :posts

  get '/account', to: 'account#show'
  put '/account', to: 'account#update'
  delete '/account', to: 'account#destroy'

  post '/signup', to: 'auth#signup'
end
