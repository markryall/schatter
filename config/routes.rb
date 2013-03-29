Schatter::Application.routes.draw do
  get 'conversations' => 'conversations#index', as: 'conversations'
  post 'conversations' => 'conversations#create'

  get 'conversations/:conversation_id/messages' => 'messages#index', as: 'messages'
  post 'conversations/:conversation_id/messages' => 'messages#create'

  post 'persona/verify' => 'persona#verify'
  get  'home' => 'home#index', as: 'home'
  get  'logout' => 'root#logout', as: 'logout'
  root to: 'root#index'
end
