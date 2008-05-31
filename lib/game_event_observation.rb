# Mix this into a controller to provide methods for watching changes to game
# objects and generating appropriate Comet messages

module GameEventObservation
	# Execute a block with game event observers in place, then issue Comet messages
	# to reflect what it saw
	def observing_game_events
		# TODO: set up observers to only watch events from a single game
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
		(@players_to_begin_turn || {}).values.each do |player|
			if player.game.casting?
				player.game.broadcast "beginCasting(#{player.id})"
			elsif player.game.combat?
				player.game.broadcast "beginCombat(#{player.id})"
			end
		end
		(@games_to_announce || {}).values.each do |game|
			game_html = render_to_string :partial => 'games/announcement', :object => game
			Meteor.shoot 'games', "announceGame(#{game.id}, #{game_html.to_json})"
		end
		(@games_to_start || {}).values.each do |game|
			game.broadcast "startGame()"
		end
		(@games_to_continue || {}).values.each do |game|
			game.broadcast "setGameState(#{game.state.to_json})"
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
	
	def on_start_game(game)
		@games_to_start ||= {}
		@games_to_start[game.id] = game
		@games_to_announce ||= {}
		@games_to_announce[game.id] = game if game.is_public?
	end

	def on_game_state_change(game)
		@games_to_continue ||= {}
		@games_to_continue[game.id] = game
	end

	def after_create_player(player)
		@players_to_put ||= {}
		@players_to_put[player.id] = player
		@games_to_announce ||= {}
		@games_to_announce[player.game.id] = player.game if player.game.is_public?
	end
	def after_save_player(player) # TODO: only announce 'important' changes
		@players_to_put ||= {}
		@players_to_put[player.id] = player
	end
	def after_player_chooses_spell(player)
		@players_to_put ||= {}
		@players_to_put[player.id] = player
	end
	def on_player_begin_turn(player)
		@players_to_put ||= {}
		@players_to_put[player.id] = player
		@players_to_begin_turn ||= {}
		@players_to_begin_turn[player.id] = player
	end
	def on_player_end_turn(player)
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
