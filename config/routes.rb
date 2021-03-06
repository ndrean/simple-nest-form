Rails.application.routes.draw do
  
  root to: 'posts#index'

  resources :posts do
    post 'save/:id', to: 'comments#save', as: 'save'
    collection do
      get :favorite
    end

    member do
      get :commentator
    end

    post 'comments/save'
    
    resources :comments, only: [:index, :new, :create]
  end

  get 'articles', to: 'posts#display_articles'
  resources :comments, only: [:destroy, :show, :edit, :update]

  delete 'erase/:id', to: "comments#erase", as: 'erase'
  
end
