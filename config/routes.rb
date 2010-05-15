ActionController::Routing::Routes.draw do |map|
  map.resources :entries, :collection => {:calendar => :get}
  map.resources :tags
  
  map.root :controller => 'entries'
end
