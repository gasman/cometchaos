module Spells
	class CreatureSpell < Spell
		delegate(:is_mountable?, :is_flying?, :is_undead?, :combat, :ranged_combat,
			:combat_range, :defence, :movement_allowance, :manoeuvre_rating,
			:magic_resistance, :casting_range, :to => :spell_variety)
	end
end
