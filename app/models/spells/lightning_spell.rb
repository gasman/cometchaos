module Spells
	class LightningSpell < Spell

		def casting_targets
			sprites = game.sprites_by_location
			target_squares = []
			target_sprites = []
			
			player.wizard_sprite.each_square_within(spell_variety.casting_range) do |x,y|
				if (sprites[[x,y]].nil?)
					target_squares << [x,y]
				else
					target_sprites << sprites[[x,y]].id unless sprites[[x,y]] == player.wizard_sprite
				end
			end
			{:spaces => target_squares, :sprites => target_sprites}
		end
		
		def perform
			return if @target_sprite.nil?
			# TODO: proper combat system
			if rand(2) > 0
				@target_sprite.die!
			end
			# TODO: check if we're supposed to return 'spell failed' if sprite doesn't die
		end

	end
end
