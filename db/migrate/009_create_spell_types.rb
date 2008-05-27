class CreateSpellTypes < ActiveRecord::Migration
	def self.up
		create_table :spell_types do |t|
			t.string :name, :null => false
			t.string :type, :null => false
			t.boolean :is_persistent, :null => false
			t.boolean :is_in_rotation, :null => false
			t.string :image
		end
	end

	def self.down
		drop_table :spell_types
	end
end
