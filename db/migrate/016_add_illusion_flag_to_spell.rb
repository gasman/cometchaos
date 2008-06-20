class AddIllusionFlagToSpell < ActiveRecord::Migration
	def self.up
		add_column :spells, :is_illusion, :boolean
	end

	def self.down
		remove_column :spells, :is_illusion
	end
end
