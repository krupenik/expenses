ActionController::Routing::Routes.draw do |map|
  map.devise_for :users, :path_names => {:sign_in => 'login', :sign_out => 'logout'}

  map.resources :entries
  map.resources :tags

  map.calendar '/calendar', :controller => 'entries', :action => 'calendar', :conditions => {:method => :get}
  map.context '/context', :controller => 'entries', :action => 'set_context', :conditions => {:method => :post}

  map.root :controller => 'entries'
end
