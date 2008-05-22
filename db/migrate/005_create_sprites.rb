class CreateSprites < ActiveRecord::Migration
	def self.up
		create_table :sprites do |t|
			t.integer :x
			t.integer :y
			t.integer :player_id
			t.string :image
			t.boolean :is_wizard, :default => false
		end
	end

	def self.down
		drop_table :sprites
	end
end
