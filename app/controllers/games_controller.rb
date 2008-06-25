class GamesController < ApplicationController
	include GameEventObservation
	
	# GET /games
	# GET /games.xml
	def index
		@games = Game.all_active_public
		@game = Game.new
		@player = Player.new

		respond_to do |format|
			format.html # index.html.erb
			format.xml  { render :xml => @games }
		end
	end

	# GET /games/1
	# GET /games/1.xml
	def show
		@game = Game.find(params[:id])
		@new_player = Player.new

		respond_to do |format|
			format.html # show.html.erb
			format.xml  { render :xml => @game }
		end
	end

	# GET /games/new
	# GET /games/new.xml
	def new
		@game = Game.new
		@player = Player.new

		respond_to do |format|
			format.html # new.html.erb
			format.xml  { render :xml => @game }
		end
	end

	# GET /games/1/edit
	def edit
		@game = Game.find(params[:id])
	end

	# POST /games
	# POST /games.xml
	def create
		@game = Game.new(params[:game])
		@player = Player.new(params[:player])
		@player.is_operator = true
		@player.game = @game # required to make @player valid

		if @player.valid? and @game.valid?
			observing_game_events(@game) do
				@game.add_player(@player)
				@game.save! # also saves player and player sprite
			end

			become_player(@player)

			respond_to do |format|
				format.html { redirect_to(@game) }
				format.xml  { render :xml => @game, :status => :created, :location => @game }
			end
		else
			respond_to do |format|
				format.html { render :action => "new" }
				format.xml  { render :xml => @game.errors, :status => :unprocessable_entity }
			end
		end
	end

	# PUT /games/1
	# PUT /games/1.xml
	def update
		@game = Game.find(params[:id])

		respond_to do |format|
			if @game.update_attributes(params[:game])
				flash[:notice] = 'Game was successfully updated.'
				format.html { redirect_to(@game) }
				format.xml  { head :ok }
			else
				format.html { render :action => "edit" }
				format.xml  { render :xml => @game.errors, :status => :unprocessable_entity }
			end
		end
	end

	# DELETE /games/1
	# DELETE /games/1.xml
	def destroy
		@game = Game.find(params[:id])
		@game.destroy

		respond_to do |format|
			format.html { redirect_to(games_url) }
			format.xml  { head :ok }
		end
	end
	
	# POST /games/1/start
	def start
		@game = Game.find(params[:id])
		unless playing? and me.is_operator?
			raise "Only operators can start the game"
		end
		raise "The game cannot be started at this time" unless @game.startable?
		observing_game_events(@game) do
			@game.start!
		end
		announce_event("The game has started. Let battle commence!")

		render :nothing => true and return if request.xhr?
		respond_to do |format|
			format.html { redirect_to(@game) }
			format.xml  { head :ok }
		end
	end
	
	# GET /games/1/casting_targets
	def casting_targets
		@game = Game.find(params[:id])
		raise "You aren't a player in this game" unless playing?
		raise Game::InvalidMove.new, "You cannot cast a spell at this time" unless me.casting?
		render :json => me.next_spell.casting_targets
	end
	
	# POST /games/1/cast_spell
	def cast_spell
		@game = Game.find(params[:id])
		raise "You aren't a player in this game" unless playing?
		@spell = me.next_spell
		observing_game_events(@game) do
			if params[:sprite_id]
				@sprite = @game.sprites.find(params[:sprite_id])
				# TODO: validate against casting targets
				me.cast_at_sprite!(@sprite)
			else
				# TODO: validate against casting targets
				me.cast_at_space!(params[:x], params[:y])
			end
		end
		
		if request.xhr?
			output = ''
			for_spells_triggering(:after_destroy) do |spell|
				output << "discardSpell(#{spell.id});"
			end
			render :text => output
		else
			format.html { redirect_to(@game) }
			format.xml  { head :ok }
		end
	end
	
	# POST /games/1/end_turn
	def end_turn
		@game = Game.find(params[:id])
		raise "You aren't a player in this game" unless playing?
		observing_game_events(@game) do
			me.end_turn
		end
	end
end
