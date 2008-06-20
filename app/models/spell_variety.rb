class SpellVariety < ActiveRecord::Base
	def instantiate
		spell = "Spells::#{spell_type}".constantize.new
		spell.spell_variety = self
		spell
	end
end
