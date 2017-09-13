Rails.application.routes.draw do
  resources :houses, only: [:new] do
    collection do
      get :token
    end
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get '/gp/:slug_id', to: 'gp#show'
  resources :iframes

  mount ApplicationAPI => '/'
end
