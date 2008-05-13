require File.dirname(__FILE__) + '/../test_helper'

class PlayersControllerTest < ActionController::TestCase
	def test_should_get_index
		get :index, :game_id => games(:public).id
		assert_response :success
		assert_not_nil assigns(:players)
	end

	def test_should_get_new
		get :new, :game_id => games(:public).id
		assert_response :success
	end

	def test_should_create_player
		assert_difference('Player.count') do
			post :create, :game_id => games(:public).id, :player => {:name => 'Bob'}
		end

		assert_redirected_to game_path(games(:public))
	end

	def test_should_show_player
		get :show, :id => players(:dumbledore).id
		assert_response :success
	end

	def test_should_get_edit
		get :edit, :id => players(:dumbledore).id
		assert_response :success
	end

	def test_should_update_player
		put :update, :id => players(:dumbledore).id, :player => { }
		assert_redirected_to player_path(assigns(:player))
	end

	def test_should_destroy_player
		assert_difference('Player.count', -1) do
			delete :destroy, :id => players(:dumbledore).id
		end

		assert_redirected_to players_path
	end
end
