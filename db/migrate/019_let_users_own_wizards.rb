class LetUsersOwnWizards < ActiveRecord::Migration
	def self.up
		add_column :players, :user_id, :integer
	end

	def self.down
		drop_column :players, :user_id
	end
end
