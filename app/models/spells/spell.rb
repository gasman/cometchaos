module Spells
	class Spell < ActiveRecord::Base
		belongs_to :player
		belongs_to :spell_variety
		
		attr_accessible # all attributes are protected by default
		
		delegate :name, :lawfulness, :casting_chance, :casting_range, :is_persistent?, :to => :spell_variety
		delegate :game_id, :game, :to => :player
	
		attr_reader :target_x, :target_y, :target_sprite, :succeeded
		
		def cast_at_space!(x,y)
			@target_x, @target_y = x, y
			@target_sprite = nil
			callback :on_cast
			@succeeded = (rand(100) < casting_chance)
			perform if succeeded

			self.destroy unless is_persistent?
		end
		
		def cast_at_sprite!(sprite)
			@target_x, @target_y = sprite.x, sprite.y
			@target_sprite = sprite
			callback :on_cast
			@succeeded = (rand(100) < casting_chance)
			perform if succeeded

			self.destroy unless is_persistent?
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
		
		def needs_illusion_flag?
			false
		end

		def casting_targets
			occupied_squares = game.sprites.collect{|sprite| [sprite.x, sprite.y]}
			available_squares = []
			
			player.wizard_sprite.each_adjacent_square do |x,y|
				available_squares << [x,y] unless occupied_squares.include?([x,y])
			end
			{:spaces => available_squares}
		end
	end
end
