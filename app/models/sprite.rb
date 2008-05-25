class Sprite < ActiveRecord::Base
	belongs_to :player
	
	def game
		player.game
	end
end
