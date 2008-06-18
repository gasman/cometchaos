module Spells
	class CreatureSpell < Spell
		delegate(:is_mountable?, :is_flying?, :is_undead?, :combat, :ranged_combat,
			:combat_range, :defence, :movement_allowance, :manoeuvre_rating,
			:magic_resistance, :casting_range, :to => :spell_variety)
		
		def perform
			player.sprites << Sprite.new(:image => spell_variety.image,
				:x => @target_x, :y => @target_y,
				:movement_allowance => spell_variety.movement_allowance)
		end
	end
end
