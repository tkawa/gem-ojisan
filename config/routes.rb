Rails.application.routes.draw do
  # devise_for :users, controllers: {omniauth_callbacks: 'authentication'}
  root 'home#index'

  resources :check_logs, only: %i(index show)
  resources :projects, only: %i(index show)

  get '/memtuner', to: 'memtuner#show'
  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end
end
