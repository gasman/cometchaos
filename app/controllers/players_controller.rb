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
			announce_event("%s has joined the game", @player.name)

			become_player(@player)
			
			if request.xhr?
				render :text => "becomePlayer(#{@player.id}, #{@player.is_operator?})"
				return
			end

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
				format.html { redirect_to(@game) }
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
		unless playing? and (@player == me or me.is_operator?)
			raise "You can't kick a player because you're not an operator!"
		end
		observing_game_events do
			@player.destroy
		end
		if @player == me
			announce_event("%s has left the game", @player.name)
		else
			announce_event("%s was kicked by %s", @player.name, me.name)
		end

		render :nothing => true and return if request.xhr?
		respond_to do |format|
			format.html { redirect_to @game }
			format.xml  { head :ok }
		end
	end
	
	# POST /players/1/op
	def op
		@player = Player.find(params[:id])
		@game = @player.game
		unless playing? and me.is_operator?
			raise "Only operators can op people"
		end
		observing_game_events do
			@player.is_operator = true
			@player.save!
		end

		@game.broadcast "assignOperator(#{@player.id}, true)"
		announce_event("%s was promoted to operator by %s", @player.name, me.name)

		render :nothing => true and return if request.xhr?
		respond_to do |format|
			format.html { redirect_to @game }
			format.xml  { head :ok }
		end
	end

	# POST /players/1/deop
	def deop
		@player = Player.find(params[:id])
		@game = @player.game
		unless playing? and me.is_operator?
			raise "Only operators can deop people"
		end
		observing_game_events do
			@player.is_operator = false
			@player.save!
		end

		@game.broadcast "assignOperator(#{@player.id}, false)"
		announce_event("%s was demoted by %s", @player.name, me.name)

		render :nothing => true and return if request.xhr?
		respond_to do |format|
			format.html { redirect_to @game }
			format.xml  { head :ok }
		end
	end
	# TODO: do something to ensure that games can't end up with no operators

end
