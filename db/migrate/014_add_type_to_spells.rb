class AddTypeToSpells < ActiveRecord::Migration
	def self.up
		rename_table :spell_types, :spell_varieties
		rename_column :spells, :spell_type_id, :spell_variety_id
		add_column :spells, :type, :string
		
	end

	def self.down
		drop_column :spells, :type
		rename_column :spells, :spell_variety_id, :spell_type_id
		rename_table :spell_varieties, :spell_types
	end
end
