class SpellsController < ApplicationController
	include GameEventObservation

	# GET /games/1/spells
	def index
		@game = Game.find(params[:game_id])
		raise "Non-players can't get their spells" unless playing?
		@spells = me.spells
		
		render :partial => 'spells/list', :object => @spells if request.xhr?
	end

	# POST /spells/1/select
	def select
		@spell = Spells::Spell.find(params[:id], :include => {:player => :game})
		@player = @spell.player
		@game = @player.game
		unless playing? and @player == me
			raise "Attempted to select a spell that isn't yours"
		end
		observing_game_events(@game) do
			@player.choose_spell!(@spell)
		end
		
		if request.xhr?
			chosen_spell_html = render_to_string(
				:partial => 'spells/chosen_spell', :object => @spell)
			render :text => "markSpellAsChosen(#{@spell.id}, #{chosen_spell_html.to_json})"
			return
		end

		respond_to do |format|
			format.html { redirect_to @game }
			format.xml  { head :ok }
		end
	end
end
