class Sprite < ActiveRecord::Base
	belongs_to :player
	
	def game
		@game ||= player.game
	end
	
	def before_destroy
		# make sure we have a reference to @game cached before the association is lost
		game
	end
end
