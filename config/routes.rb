Schatter::Application.routes.draw do
  resources :conversation
  post 'persona/verify' => 'persona#verify'
  get  'home' => 'home#index', as: 'home'
  get  'logout' => 'root#logout', as: 'logout'
  root to: 'root#index'
end
