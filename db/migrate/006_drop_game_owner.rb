class DropGameOwner < ActiveRecord::Migration
	def self.up
		remove_column :games, :owner_id
	end

	def self.down
		add_column :games, :owner_id, :integer
	end
end
