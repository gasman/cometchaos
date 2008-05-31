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
		@player.game = @game
		@game.players << @player

		if @player.valid? and @game.valid?
			observing_game_events do
				@game.save!
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
		observing_game_events do
			@game.start!
		end
		announce_event("The game has started. Let battle commence!")

		render :nothing => true and return if request.xhr?
		respond_to do |format|
			format.html { redirect_to(@game) }
			format.xml  { head :ok }
		end
	end
	
	# GET /games/1/casting_positions
	def casting_positions
		@game = Game.find(params[:id])
		raise "You aren't a player in this game" unless playing?
		render :json => me.casting_positions
	end
	
	# POST /games/1/cast_spell
	def cast_spell
		@game = Game.find(params[:id])
		raise "You aren't a player in this game" unless playing?
		observing_game_events do
			me.cast!(params[:x], params[:y])
		end
		announce_event("%s casts %s", me.name, me.next_spell.name)
	end
	
	# POST /games/1/end_turn
	def end_turn
		@game = Game.find(params[:id])
		raise "You aren't a player in this game" unless playing?
		observing_game_events do
			me.end_turn
		end
	end
end
