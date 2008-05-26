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
		(@players_to_put || {}).values.each do |player|
			next if @players_to_destroy and @players_to_destroy.has_key?(player.id)
			player_html = render_to_string :partial => 'games/player', :object => player
			player.game.broadcast "putPlayer(#{player.id}, #{player_html.to_json})"
		end
		(@players_to_destroy || {}).values.each do |player|
			player.game.broadcast "removePlayer(#{player.id})"
		end
		(@games_to_announce || {}).values.each do |game|
			game_html = render_to_string :partial => 'games/announcement', :object => game
			Meteor.shoot 'games', "announceGame(#{game.id}, #{game_html.to_json})"
		end
		(@sprites_to_put || {}).values.each do |sprite|
			next if @sprites_to_destroy and @sprites_to_destroy.has_key?(sprite.id)
			sprite_js = render_to_string(:partial => 'games/sprite', :object => sprite)
			sprite.game.broadcast sprite_js
		end
		(@sprites_to_destroy || {}).values.each do |sprite|
			sprite.game.broadcast "removeSprite(#{sprite.id})"
		end
	end
	
	def after_save_game(game) # TODO: only announce 'important' changes
		@games_to_announce ||= {}
		@games_to_announce[game.id] = game if game.is_public?
	end
	def after_create_player(player)
		@players_to_put ||= {}
		@players_to_put[player.id] = player
		@games_to_announce ||= {}
		@games_to_announce[player.game.id] = player.game if player.game.is_public?
	end
	def after_save_player(player)
		@players_to_put ||= {}
		@players_to_put[player.id] = player
	end
	def after_destroy_player(player)
		@players_to_destroy ||= {}
		@players_to_destroy[player.id] = player
		@games_to_announce ||= {}
		@games_to_announce[player.game.id] = player.game if player.game.is_public?
	end
	def after_save_sprite(sprite) # TODO: only announce 'important' changes
		@sprites_to_put ||= {}
		@sprites_to_put[sprite.id] = sprite
	end
	def after_destroy_sprite(sprite)
		@sprites_to_destroy ||= {}
		@sprites_to_destroy[sprite.id] = sprite
	end
end
