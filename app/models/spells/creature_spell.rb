module Spells
	class CreatureSpell < Spell
		attr_accessible :is_illusion
	
		delegate(:is_mountable?, :is_flying?, :is_undead?, :combat, :ranged_combat,
			:combat_range, :defence, :movement_allowance, :manoeuvre_rating,
			:magic_resistance, :casting_range, :to => :spell_variety)
		
		def perform
			player.sprites << Sprite.new(:image => spell_variety.image,
				:x => @target_x, :y => @target_y, :is_illusion => is_illusion,
				:movement_allowance => spell_variety.movement_allowance)
		end

		def needs_illusion_flag?
			is_illusion.nil?
		end
		
		def casting_chance
			is_illusion? ? 100 : super
		end
	end
end
