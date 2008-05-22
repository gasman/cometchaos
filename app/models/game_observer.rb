class GameObserver < ActiveRecord::Observer
	def after_save(game)
		if game.is_public? and game.owner
			renderer = InstantRenderer.new(:controller => 'games', :action => 'show')
			game_html = renderer.render 'games/_announcement', :announcement => game
			Meteor.shoot 'games', "addGame(#{game.id}, #{game_html.to_json})"
		end
	end
end
