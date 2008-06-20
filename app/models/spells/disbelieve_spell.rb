module Spells
	class DisbelieveSpell < Spell
		def perform
			if @target_sprite.nil? or !@target_sprite.is_illusion?
				@succeeded = false
			else
				@succeeded = true
				@target_sprite.destroy
			end
		end
		
		def casting_targets
			# TODO: exclude sprites that we want to avoid casting disbelieve on, e.g. mounted wizards, corpses
			{:sprites => game.sprite_ids}
		end
	end
end
