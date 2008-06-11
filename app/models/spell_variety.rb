class SpellVariety < ActiveRecord::Base
	def instantiate
		"Spells::#{spell_type}".constantize.new(:spell_variety => self)
	end
end
