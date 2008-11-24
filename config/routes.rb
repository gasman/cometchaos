ActionController::Routing::Routes.draw do |map|
	map.root :controller => 'games'

	map.resources :users
	map.resource :session

	map.resources :players, :member => { :op => :post, :deop => :post }
	map.resources :games, :has_many => [:players], :member => {
		:start => :post, :casting_targets => :get, :cast_spell => :post,
		:end_turn => :post } do |games|
		games.resources :spells
	end
	
	map.resources :spells, :member => { :select => :post }
	map.resources :sprites, :member => { :move_targets => :get, :move => :post, :attack => :post }

	map.login '/login', :controller => 'sessions', :action => 'new'
	map.logout '/logout', :controller => 'sessions', :action => 'destroy'
	map.edit_user '/edit_user', :controller => 'users', :action => 'edit'

	# Install the default routes as the lowest priority.
	map.connect ':controller/:action/:id'
	map.connect ':controller/:action/:id.:format'
end
