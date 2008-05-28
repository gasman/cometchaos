class AddSpellCastingFieldsToPlayer < ActiveRecord::Migration
	def self.up
		add_column :players, :has_chosen_spell, :boolean, :null => false, :default => false
		add_column :players, :next_spell_id, :integer
	end

	def self.down
		drop_column :players, :has_chosen_spell
		drop_column :players, :next_spell_id
	end
end
