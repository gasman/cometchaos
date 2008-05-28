class SpellsController < ApplicationController

	# GET /games/1/spells
	def index
		@game = Game.find(params[:game_id])
		raise "Non-players can't get their spells" unless playing?
		@spells = me.spells
		
		render :partial => 'spells/list', :object => @spells if request.xhr?
	end

	# POST /spells/1/select
	def select
		@spell = Spell.find(params[:id], :include => {:player => :game})
		@player = @spell.player
		@game = @player.game
		unless playing? and @player == me
			raise "Attempted to select a spell that isn't yours"
		end

	end
end
