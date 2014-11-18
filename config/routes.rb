AngularBook::Application.routes.draw do
  get '/games', to: 'games#index'
  root 'games#index'
end
