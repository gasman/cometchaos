# Mix this into a controller to provide methods for watching changes to game
# objects and generating appropriate Comet messages

module GameEventObservation
	# Execute a block with game event observers in place, then issue Comet messages
	# to reflect what it saw
	def observing_game_events(game)
		@eventful_objects = {}
		GameObserver.instance.add_observer(self, game)
		yield
		GameObserver.instance.delete_observer(self, game)
		
		global_responses = ''
		game_responses = ''

		for_players_triggering(:after_create) do |player|
			player_html = render_to_string :partial => 'games/player', :object => player
			game_responses << "putPlayer(#{player.id}, #{player_html.to_json});"
			
			if game.is_public?
				# update number of players in announcement
				game_html = render_to_string :partial => 'games/announcement', :object => game
				global_responses << "announceGame(#{game.id}, #{game_html.to_json});"
			end
		end

		for_players_triggering(:on_change_appearance) do |player|
			player_html = render_to_string :partial => 'games/player', :object => player
			game_responses << "putPlayer(#{player.id}, #{player_html.to_json});"
		end

		for_players_triggering(:on_assign_operator) do |player|
			game_responses << "assignOperator(#{player.id});"
		end
		for_players_triggering(:on_revoke_operator) do |player|
			game_responses << "revokeOperator(#{player.id});"
		end
		
		for_players_triggering(:after_destroy) do |player|
			game_responses << "removePlayer(#{player.id});"

			if game.is_public?
				# update number of players in announcement
				game_html = render_to_string :partial => 'games/announcement', :object => game
				global_responses << "announceGame(#{game.id}, #{game_html.to_json});"
			end
		end
		
		for_games_triggering(:become_startable) do |game|
			game_responses << "setGameStartable(true);"
		end
		for_games_triggering(:become_unstartable) do |game|
			game_responses << "setGameStartable(false);"
		end
		for_games_triggering(:become_joinable) do |game|
			game_responses << "setGameJoinable(true);"
		end
		for_games_triggering(:become_unjoinable) do |game|
			game_responses << "setGameJoinable(false);"
		end
		for_games_triggering(:on_start) do |game|
			game_responses << "startGame();"
		end
		
		for_players_triggering(:on_end_choosing_spells) do |player|
			game_responses << "endChoosingSpells(#{player.id});"
		end
		
		for_players_triggering(:on_begin_casting) do |player|
			game_responses << "beginCasting(#{player.id});"
		end
		for_players_triggering(:on_end_casting) do |player|
			game_responses << "endCasting(#{player.id});"
		end
		
		# TODO: 'cast spell' event

		for_players_triggering(:on_begin_fighting) do |player|
			game_responses << "beginFighting(#{player.id});"
		end
		for_players_triggering(:on_end_fighting) do |player|
			game_responses << "endFighting(#{player.id});"
		end
		
		# must happen after end_turn so that the last player doesn't immediately get de-highlighted
		for_games_triggering(:on_start_choosing_spells) do |game|
			game_responses << "startChoosingSpells();"
		end

		for_sprites_triggering(:after_save) do |sprite|
			sprite_js = render_to_string(:partial => 'games/sprite', :object => sprite)
			game_responses << sprite_js
		end
		for_sprites_triggering(:after_destroy) do |sprite|
			game_responses << "removeSprite(#{sprite.id});"
		end
		
		game.broadcast game_responses unless game_responses.blank?
		Meteor.shoot 'games', global_responses unless global_responses.blank?
	end
	
	def receive_event(class_name, event, obj)
		@eventful_objects ||= {}
		@eventful_objects[class_name] ||= {}
		@eventful_objects[class_name][event] ||= []
		@eventful_objects[class_name][event] << obj unless @eventful_objects[class_name][event].include?(obj)
	end
	
	def for_games_triggering(event)
		if @eventful_objects[:game] and @eventful_objects[:game][event]
			@eventful_objects[:game][event].each{|game| yield game}
		end
	end

	def for_players_triggering(event)
		if @eventful_objects[:player] and @eventful_objects[:player][event]
			@eventful_objects[:player][event].each{|player| yield player}
		end
	end

	def for_sprites_triggering(event)
		if @eventful_objects[:sprite] and @eventful_objects[:sprite][event]
			@eventful_objects[:sprite][event].each{|sprite| yield sprite}
		end
	end

	def for_spells_triggering(event)
		if @eventful_objects[:spell] and @eventful_objects[:spell][event]
			@eventful_objects[:spell][event].each{|spell| yield spell}
		end
	end
	
end
