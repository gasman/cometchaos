module Spells
	class Spell < ActiveRecord::Base
		belongs_to :player
		belongs_to :spell_variety

		delegate :name, :lawfulness, :casting_chance, :casting_range, :to => :spell_variety
	
		def cast!(x,y)
			player.sprites << Sprite.new(:image => spell_variety.image,
				:x => x, :y => y, :movement_allowance => spell_variety.movement_allowance)
			self.destroy
		end
		
		def lawfulness_string
			if lawfulness < 0
				"Chaos #{-lawfulness}"
			elsif lawfulness > 0
				"Law #{lawfulness}"
			else
				""
			end
		end
	end
end
