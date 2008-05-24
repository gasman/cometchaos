# Mix this into a controller to provide methods for watching changes to game
# objects and generating appropriate Comet messages

module GameEventObservation
	# Execute a block with game event observers in place, then issue Comet messages
	# to reflect what it saw
	def observing_game_events
		GameObserver.instance.add_observer(self)
		PlayerObserver.instance.add_observer(self)
#		Sprite.add_observer(self)
		yield
		GameObserver.instance.delete_observer(self)
		PlayerObserver.instance.delete_observer(self)
#		Sprite.delete_observer(self)
		(@games_to_announce || []).uniq.each do |game|
			game_html = render_to_string :partial => 'games/announcement', :object => game
			Meteor.shoot 'games', "announceGame(#{game.id}, #{game_html.to_json})"
		end
		(@players_to_add || []).uniq.each do |player|
			player_html = render_to_string :partial => 'games/player', :object => player
			player.game.broadcast "addPlayer(#{player.id}, #{player_html.to_json})"
		end
	end
	
	def after_save_game(game) # TODO: only announce 'important' changes
		@games_to_announce ||= []
		@games_to_announce << game if game.is_public?
	end
	def after_create_player(player)
		@players_to_add ||= []
		@players_to_add << player
		@games_to_announce ||= []
		@games_to_announce << player.game if player.game.is_public?
	end
end
