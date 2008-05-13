# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
	helper :all # include all helpers, all the time

	# See ActionController::RequestForgeryProtection for details
	# Uncomment the :secret if you're not using the cookie session store
	protect_from_forgery :only => [:create, :update, :destroy] # :secret => 'fb148b031dcb37b71029323d7ccfb80e'

	private
	helper_method :playing?, :me, :become_player

	def playing?
		@playing ||= session[:games] &&
			session[:games][@game.id] &&
			!!session[:games][@game.id][:player_id]
	end

	def me
		@me ||= (playing? ? Player.find(session[:games][@game.id][:player_id]) : false) unless @me == false
	end
	
	def become_player(player)
		session[:games] ||= {}
		session[:games][player.game.id] = {:player_id => player.id}
		@me = @playing = nil # forget cached values of @me and @playing
	end

end
