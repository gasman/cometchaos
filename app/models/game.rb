class Game < ActiveRecord::Base
	WIZARD_START_POSITIONS = [
		[],
		[[1,4]],
		[[1,4],[13,4]],
		[[1,8],[7,1],[13,8]],
		[[1,8],[1,1],[13,1],[13,8]],
		[[3,9],[0,3],[7,0],[14,3],[11,9]],
		[[0,8],[0,1],[7,0],[14,1],[14,8],[7,9]],
		[[4,9],[0,6],[1,1],[7,0],[13,1],[14,6],[10,9]],
		[[0,9],[0,4],[0,0],[7,0],[14,0],[14,4],[14,9],[7,9]]
	]
	has_many :players, :order => 'position'
	# owner is the earliest-created player of this game
	has_one :owner, :class_name => 'Player', :order => 'created_at'
	has_many :sprites, :through => :players
	
	def channel
		"game_#{self.id}"
	end
	
	def broadcast(message)
		Meteor.shoot self.channel, message
	end
	
	def self.all_active_public
		find(:all, :conditions => "games.is_public = 't' AND players.id IS NOT NULL", :include => :owner)
	end
	
	def set_wizard_start_positions
		starts = WIZARD_START_POSITIONS[self.players.size]
		self.players.each_with_index do |player, i|
			player.wizard_sprite.update_attributes(:x => starts[i][0], :y => starts[i][1])
		end
	end
end
