Expenses::Application.routes.draw do
  devise_for :users, :path_names => {:sign_in => 'login', :sign_out => 'logout'}

  resources :entries
  resources :tags

  match '/calendar' => 'entries#calendar', :as => :calendar, :via => :get
  match '/context' => 'entries#set_context', :as => :context, :via => :post

  root :to => "entries#index"
end
