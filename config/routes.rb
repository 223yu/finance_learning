Rails.application.routes.draw do

  root 'homes#top'
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    omniauth_callbacks: 'users/omniauth_callbacks'
  }
  resource :users, only: [:show, :edit, :update] do
    post 'start', on: :collection
  end
  resources :contents, only: [:index, :create, :destroy]
  resources :accounts, only: [:index, :create, :edit, :update, :destroy]
  resources :single_entries, only: [:index, :create, :edit, :update, :destroy] do
    get 'select', on: :collection
  end
  resources :cash_entries, only: [:index, :create, :edit, :update, :destroy] do
    get 'select', on: :collection
  end
   resources :card_entries, only: [:index, :create, :edit, :update, :destroy] do
    get 'select', on: :collection
  end
  resources :trial_balances, only: [:index] do
    get 'select', on: :collection
  end
  resources :transition_tables, only: [:index] do
    get 'select', on: :collection
  end
  resources :ledgers, only: [:index, :edit, :update, :destroy] do
    get 'select', on: :collection
  end

end
