Rails.application.routes.draw do

  root 'homes#top'
  post '/guest_sign_in', to: 'homes#guest_sign_in'
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations',
    omniauth_callbacks: 'users/omniauth_callbacks'
  }
  resource :users, only: [:show] do
    post 'start', on: :collection
  end
  resource :contents, only: [:show, :create, :destroy]
  resources :accounts, only: [:index, :create, :edit, :update, :destroy] do
    get 'search', on: :collection
    get 'search_sub', on: :collection
  end
  resources :single_entries, only: [:index, :create, :edit, :update, :destroy] do
    get 'select', on: :collection
    get 'search', on: :collection
    get 'scroll', on: :collection
  end
  resources :cash_entries, only: [:index, :create, :edit, :update, :destroy] do
    get 'select', on: :collection
    get 'search', on: :collection
    get 'scroll', on: :collection
  end
   resources :card_entries, only: [:index, :create, :edit, :update, :destroy] do
    get 'select', on: :collection
    get 'search', on: :collection
  end
  resources :trial_balances, only: [:index] do
    get 'select', on: :collection
  end
  resources :transition_tables, only: [:index] do
    get 'select', on: :collection
  end
  resources :ledgers, only: [:index ] do
    get 'select', on: :collection
  end
  resource :years, only: [:update] do
    post 'select', on: :collection
  end
  resources :single_entry_imports, only: [:index, :create, :edit, :update, :destroy] do
    get 'import', on: :collection
    delete 'all_destroy', on: :collection
    get 'download', on: :collection
  end

end
