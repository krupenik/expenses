Expenses::Application.routes.draw do
  devise_for :users, :path_names => {:sign_in => 'login', :sign_out => 'logout'}

  resources :entries
  resources :tags

  post '/context' => 'entries#set_context', :as => :context
  post '/milestone' => 'entries#set_milestone', :as => :milestone

  root :to => "entries#index"
end
