class ExtendSpellVarieties < ActiveRecord::Migration
	def self.up
		rename_column :spell_varieties, :type, :spell_type
		add_column :spell_varieties, :casting_chance, :integer
		add_column :spell_varieties, :lawfulness, :integer
		add_column :spell_varieties, :is_mountable, :boolean
		add_column :spell_varieties, :is_flying, :boolean
		add_column :spell_varieties, :is_undead, :boolean
		add_column :spell_varieties, :combat, :integer
		add_column :spell_varieties, :ranged_combat, :integer
		add_column :spell_varieties, :combat_range, :integer
		add_column :spell_varieties, :defence, :integer
		add_column :spell_varieties, :manoeuvre_rating, :integer
		add_column :spell_varieties, :magic_resistance, :integer
		add_column :spell_varieties, :casting_range, :integer
	end

	def self.down
		rename_column :spell_varieties, :spell_type, :type
		remove_column :spell_varieties, :casting_chance
		remove_column :spell_varieties, :lawfulness
		remove_column :spell_varieties, :is_mountable
		remove_column :spell_varieties, :is_flying
		remove_column :spell_varieties, :is_undead
		remove_column :spell_varieties, :combat
		remove_column :spell_varieties, :ranged_combat
		remove_column :spell_varieties, :combat_range
		remove_column :spell_varieties, :defence
		remove_column :spell_varieties, :manoeuvre_rating
		remove_column :spell_varieties, :magic_resistance
		remove_column :spell_varieties, :casting_range
	end
end
