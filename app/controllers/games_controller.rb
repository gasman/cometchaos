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
		@new_player = Player.new if not playing?

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
	
end
