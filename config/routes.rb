ActionController::Routing::Routes.draw do |map|
	map.resources :players
	map.resources :games, :has_many => :players

	map.root :controller => 'games'

	# See how all your routes lay out with "rake routes"

	# Install the default routes as the lowest priority.
	map.connect ':controller/:action/:id'
	map.connect ':controller/:action/:id.:format'
end
