# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
	helper :all # include all helpers, all the time

	# See ActionController::RequestForgeryProtection for details
	# Uncomment the :secret if you're not using the cookie session store
	# protect_from_forgery :only => [:create, :update, :destroy] # :secret => 'fb148b031dcb37b71029323d7ccfb80e'

	# FIXME: protect_from_forgery has inherent compatibility issues with Comet,
	# because users are being served HTML fragments within the context of someone
	# else's request, and we need to ensure that those fragments don't contain the
	# wrong person's authenticity token. Ideally we want to reinstate
	# protect_from_forgery in a way that's compatible with Comet - keeping the
	# authenticity token around in a JS variable and attaching this at the point
	# of receiving Comet messages.

	private
	helper_method :playing?, :me, :become_player

	def playing?
		@playing ||= session[:games] &&
			session[:games][@game.id] &&
			session[:games][@game.id][:player_id] &&
			!!(@me = Player.find_by_id(session[:games][@game.id][:player_id]))
	end

	def me
		@me if playing?
	end
	
	def become_player(player)
		session[:games] ||= {}
		session[:games][player.game.id] = {:player_id => player.id}
		@me = @playing = nil # forget cached values of @me and @playing
	end

	def announce_event(*event)
		event_html = render_to_string(:partial => 'games/event', :object => event)
		@game.broadcast "logEvent(#{event_html.to_json})"
	end
end
