class CreateSpells < ActiveRecord::Migration
	def self.up
		create_table :spells do |t|
			t.integer :player_id, :null => false
			t.integer :spell_type_id, :null => false
		end
	end

	def self.down
		drop_table :spells
	end
end
