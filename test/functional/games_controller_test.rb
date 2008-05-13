require File.dirname(__FILE__) + '/../test_helper'

class GamesControllerTest < ActionController::TestCase
	def test_should_get_index
		get :index
		assert_response :success
		assert_equal [games(:public)], assigns(:games)
	end

	def test_should_get_new
		get :new
		assert_response :success
	end

	def test_should_create_game
		assert_difference('Game.count') do
			post :create, :player => {:name => 'Bob'}, :game => {:is_public => true}
		end

		game = assigns(:game)
		assert_redirected_to game_path(game)
		assert_equal [assigns(:player)], game.players
		assert_equal assigns(:player), game.owner
		assert_equal assigns(:player).id, session[:games][game.id][:player_id]
	end

	def test_should_show_game
		get :show, :id => games(:public).id
		assert_response :success
	end

	def test_should_get_edit
		get :edit, :id => games(:public).id
		assert_response :success
	end

	def test_should_update_game
		put :update, :id => games(:public).id, :game => { }
		assert_redirected_to game_path(assigns(:game))
	end

	def test_should_destroy_game
		assert_difference('Game.count', -1) do
			delete :destroy, :id => games(:public).id
		end

		assert_redirected_to games_path
	end
end
