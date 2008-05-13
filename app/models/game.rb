class Game < ActiveRecord::Base
	has_many :players
	belongs_to :owner, :class_name => 'Player', :foreign_key => 'owner_id'
	
	def channel
		"game_#{self.id}"
	end
	
	def self.all_active_public
		find(:all, :conditions => "games.is_public = 't' AND games.owner_id IS NOT NULL", :include => :owner)
	end
end
