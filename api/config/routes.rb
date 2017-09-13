Rails.application.routes.draw do
  resources :houses, only: [:new] do
    collection do
      get :token
    end
  end

  get '/gp/:slug_id', to: 'gp#show'

  resources :iframes

  mount ApplicationAPI => '/'
end
