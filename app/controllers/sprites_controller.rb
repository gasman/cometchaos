class SpritesController < ApplicationController
	include GameEventObservation

	# GET /sprites/1/move_targets
	def move_targets
		@sprite = Sprite.find(params[:id])
		@player = @sprite.player
		@game = @player.game
		raise "That isn't your sprite" unless playing? and @player == me
		raise "You cannot move creatures at this time" unless @game.fighting?
		render :json => @sprite.move_targets
	end

	# POST /sprites/1/move
	def move
		@sprite = Sprite.find(params[:id])
		@player = @sprite.player
		@game = @player.game
		raise "That isn't your sprite" unless playing? and @player == me
		raise "You cannot move creatures at this time" unless @game.fighting?
		observing_game_events(@game) do
			@sprite.move!(params[:x], params[:y])
		end
		render :json => @sprite.move_targets
	end

	# POST /sprites/1/attack
	def attack
		@sprite = Sprite.find(params[:id])
		@player = @sprite.player
		@game = @player.game
		raise "That isn't your sprite" unless playing? and @player == me
		raise "You cannot move creatures at this time" unless @game.fighting?
		observing_game_events(@game) do
			@sprite.attack!(Sprite.find(params[:sprite_id]))
		end
		render :json => @sprite.move_targets
	end

end
