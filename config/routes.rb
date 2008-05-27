ActionController::Routing::Routes.draw do |map|
	map.resources :players, :member => { :op => :post, :deop => :post }
	map.resources :games, :has_many => [:players], :member => { :start => :post } do |games|
		map.resources :spells, :member => { :select => :post }
	end

	map.root :controller => 'games'

	# See how all your routes lay out with "rake routes"

	# Install the default routes as the lowest priority.
	map.connect ':controller/:action/:id'
	map.connect ':controller/:action/:id.:format'
end
