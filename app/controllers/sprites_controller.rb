class SpritesController < ApplicationController
	include GameEventObservation

	# GET /sprites/1/move_positions
	def move_positions
		@sprite = Sprite.find(params[:id])
		@player = @sprite.player
		@game = @player.game
		raise "That isn't your sprite" unless playing? and @player == me
		raise "You cannot move creatures at this time" unless @game.combat?
		render :json => @sprite.move_positions
	end

	# POST /sprites/1/move
	def move
		@sprite = Sprite.find(params[:id])
		@player = @sprite.player
		@game = @player.game
		raise "That isn't your sprite" unless playing? and @player == me
		raise "You cannot move creatures at this time" unless @game.combat?
		observing_game_events(@game) do
			@sprite.move!(params[:x], params[:y])
		end
		render :json => @sprite.move_positions
	end

end
