Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  resources :merchants do
    resources :items, only: %i[index show edit update new create]
    resources :dashboard, only: [:index]
    resources :discounts 
    resources :invoices, only: %i[index show] do
      resources :invoice_items, only: %i[edit update]
    end
    # resources :invoice_items, only: %i[edit update]
  end

  namespace :admin do
    root to: 'dashboard#index', as: 'dashboard'
    resources :merchants, only: %i[index show edit update new create]
    resources :invoices, only: %i[index show edit update]
  end
end
