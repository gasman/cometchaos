# Mix this into a controller to provide methods for watching changes to game
# objects and generating appropriate Comet messages

module GameEventObservation
	# Execute a block with game event observers in place, then issue Comet messages
	# to reflect what it saw
	def observing_game_events
		GameObserver.instance.add_observer(self)
		PlayerObserver.instance.add_observer(self)
		SpriteObserver.instance.add_observer(self)
		yield
		GameObserver.instance.delete_observer(self)
		PlayerObserver.instance.delete_observer(self)
		SpriteObserver.instance.delete_observer(self)
		(@players_to_add || {}).values.each do |player|
			player_html = render_to_string :partial => 'games/player', :object => player
			player.game.broadcast "addPlayer(#{player.id}, #{player_html.to_json})"
			announce_event(player.game, "%s has joined the game", player.name)
		end
		(@games_to_announce || {}).values.each do |game|
			game_html = render_to_string :partial => 'games/announcement', :object => game
			Meteor.shoot 'games', "announceGame(#{game.id}, #{game_html.to_json})"
		end
		(@sprites_to_put || {}).values.each do |sprite|
			#raise "sprite object_id = #{sprite.object_id}, coords = #{sprite.x},#{sprite.y}; wizard_sprite object_id = #{sprite.player.wizard_sprite.object_id}, coords = #{sprite.player.wizard_sprite.x},#{sprite.player.wizard_sprite.y}"
			sprite_js = render_to_string(:partial => 'games/sprite', :object => sprite)
			sprite.game.broadcast sprite_js
		end
	end
	
	def after_save_game(game) # TODO: only announce 'important' changes
		@games_to_announce ||= {}
		@games_to_announce[game.id] = game if game.is_public?
	end
	def after_create_player(player)
		@players_to_add ||= {}
		@players_to_add[player.id] = player
		@games_to_announce ||= {}
		@games_to_announce[player.game.id] = player.game if player.game.is_public?
	end
	def after_save_sprite(sprite) # TODO: only announce 'important' changes
		@sprites_to_put ||= {}
		@sprites_to_put[sprite.id] = sprite
	end
	
	private
	def announce_event(game, *event)
		event_html = render_to_string(:partial => 'games/event', :object => event)
		game.broadcast "logEvent(#{event_html.to_json})"
	end
end
