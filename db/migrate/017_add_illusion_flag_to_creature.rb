class AddIllusionFlagToCreature < ActiveRecord::Migration
	def self.up
		add_column :sprites, :is_illusion, :boolean, :null => false, :default => false
		update "UPDATE sprites SET is_illusion = false"
	end

	def self.down
		remove_column :sprites, :is_illusion
	end
end
