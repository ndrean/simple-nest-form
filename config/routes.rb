Rails.application.routes.draw do
  
  root to: 'posts#index'

  resources :posts do
    post 'comments/save'
    delete 'comments/:id', to: 'comments#erase'
    resources :comments do
      
    end
  end
  
end
