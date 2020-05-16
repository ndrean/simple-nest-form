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
    #delete 'comments/:id', to: 'comments#erase'
    resources :comments, only: [:index, :new, :create]
  end

  resources :comments, only: [:destroy, :show, :edit, :update]

  delete 'erase/:id', to: "comments#erase", as: 'erase'
  
end
