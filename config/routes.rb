Expenses::Application.routes.draw do
  devise_for :users, :path_names => {:sign_in => 'login', :sign_out => 'logout'}

  resources :entries
  resources :tags

  get '/calendar' => 'entries#calendar', :as => :calendar
  post '/context' => 'entries#set_context', :as => :context

  root :to => "entries#index"
end
