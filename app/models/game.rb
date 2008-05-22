class Game < ActiveRecord::Base
	has_many :players, :order => 'position'
	belongs_to :owner, :class_name => 'Player', :foreign_key => 'owner_id'
	has_many :sprites, :through => :players
	
	def channel
		"game_#{self.id}"
	end
	
	def broadcast(message)
		Meteor.shoot self.channel, message
	end
	
	def self.all_active_public
		find(:all, :conditions => "games.is_public = 't' AND games.owner_id IS NOT NULL", :include => :owner)
	end
end
