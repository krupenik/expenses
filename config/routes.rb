ActionController::Routing::Routes.draw do |map|
  map.devise_for :users, :path_names => {:sign_in => 'login', :sign_out => 'logout'}
  map.resources :entries, :collection => {:calendar => :get}
  map.resources :tags
  
  map.root :controller => 'entries'
end
