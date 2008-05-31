class Spell < ActiveRecord::Base
	belongs_to :player
	belongs_to :spell_type, :class_name => 'SpellTypes::SpellType'

	delegate :name, :to => :spell_type
	
	def cast!(x,y)
		player.sprites << Sprite.new(:image => spell_type.image,
			:x => x, :y => y, :movement_allowance => spell_type.movement_allowance)
		self.destroy
	end
end
