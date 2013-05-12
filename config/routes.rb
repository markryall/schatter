Schatter::Application.routes.draw do
  resources :conversations do
    resources :messages
    resources :people
  end

  resources :messages
  resources :people

  post 'personacallback' => 'root#persona_callback'
  get 'oauth2callback' => 'root#google_oauth_callback'
  get 'logout' => 'root#logout', as: 'logout'
  get 'home' => 'home#index', as: 'home'

  root to: 'root#index'
end
