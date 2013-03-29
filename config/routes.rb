Schatter::Application.routes.draw do
  post 'persona/verify' => 'persona#verify'
  get  'home' => 'home#index', as: 'home'
  root to: 'root#index'
end
