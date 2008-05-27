class SpellsController < ApplicationController

	# GET /games/1/spells
	def index
		@game = Game.find(params[:game_id])
		raise "Non-players can't get their spells" unless playing?
		@spells = me.spells
		
		render :partial => 'spells/list', :object => @spells if request.xhr?
	end

	def select
	end
end
