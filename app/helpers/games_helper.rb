module GamesHelper
	def playing?
		@playing ||= session[:games] &&
			session[:games][@game.id] &&
			!!session[:games][@game.id][:player_id]
	end

	def me
		@me ||= (playing? ? Player.find(session[:games][@game.id][:player_id]) : false) unless @me == false
	end
end
