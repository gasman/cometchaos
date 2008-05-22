class PlayersController < ApplicationController

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

		respond_to do |format|
			if @player.save
				become_player(@player)
				player_html = render_to_string :partial => 'games/player', :object => @player
				@game.broadcast "addPlayer(#{@player.id}, #{player_html.to_json})"
				if @game.is_public?
					game_html = render_to_string :partial => 'games/announcement', :object => @game
					Meteor.shoot 'games', "updateGame(#{@game.id}, #{game_html.to_json})"
				end
				format.html { redirect_to(@game) }
				format.xml  { render :xml => @player, :status => :created, :location => @player }
			else
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
		@player.destroy

		respond_to do |format|
			format.html { redirect_to(players_url) }
			format.xml  { head :ok }
		end
	end

end
