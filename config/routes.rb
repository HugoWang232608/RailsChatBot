Rails.application.routes.draw do
  get 'sessions/new'
  post 'sessions/create'

  get 'applicants/new'
  # save create information
  post 'applicants/create'

  root 'welcome#index'
  
  get 'welcome/index'
  get 'chatrooms/index'

  resources :users do 
    resources :messages
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
