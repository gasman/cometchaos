class PlayersController < ApplicationController
	include GameEventObservation

	# GET /games/1/players
	# GET /games/1/players.xml
	def index
		@game = Game.find(params[:game_id])
		@players = @game.players

		respond_to do |format|
			format.html # index.html.erb
			format.xml  { render :xml => @players }
		end
	end

	# GET /players/1
	# GET /players/1.xml
	def show
		@player = Player.find(params[:id])

		respond_to do |format|
			format.html # show.html.erb
			format.xml  { render :xml => @player }
		end
	end

	# GET /games/1/players/new
	# GET /games/1/players/new.xml
	def new
		@game = Game.find(params[:game_id])
		@player = Player.new

		respond_to do |format|
			format.html # new.html.erb
			format.xml  { render :xml => @player }
		end
	end

	# GET /players/1/edit
	def edit
		@player = Player.find(params[:id])
	end

	# POST /games/1/players
	# POST /games/1/players.xml
	def create
		@game = Game.find(params[:game_id])
		@player = Player.new(params[:player])
		@player.game = @game
		
		if @player.valid?
			observing_game_events do
				@game.players << @player
			end
			announce_event(@game, "%s has joined the game", @player.name)

			become_player(@player)

			respond_to do |format|
				format.html { redirect_to(@game) }
				format.xml  { render :xml => @player, :status => :created, :location => @player }
			end
		else
			respond_to do |format|
				format.html { render :action => "new" }
				format.xml  { render :xml => @player.errors, :status => :unprocessable_entity }
			end
		end
	end

	# PUT /players/1
	# PUT /players/1.xml
	def update
		@player = Player.find(params[:id])

		respond_to do |format|
			if @player.update_attributes(params[:player])
				flash[:notice] = 'Player was successfully updated.'
				format.html { redirect_to(@player) }
				format.xml  { head :ok }
			else
				format.html { render :action => "edit" }
				format.xml  { render :xml => @player.errors, :status => :unprocessable_entity }
			end
		end
	end

	# DELETE /players/1
	# DELETE /players/1.xml
	def destroy
		@player = Player.find(params[:id])
		@game = @player.game
		raise "You can't kick a player because you're not playing!" unless playing?
		observing_game_events do
			@player.destroy
		end
		if @player == me
			announce_event(@game, "%s has left the game", @player.name)
		else
			announce_event(@game, "%s was kicked by %s", @player.name, me.name)
		end

		respond_to do |format|
			format.html { redirect_to @player.game }
			format.xml  { head :ok }
		end
	end

end
