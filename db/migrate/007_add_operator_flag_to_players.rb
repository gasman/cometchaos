class AddOperatorFlagToPlayers < ActiveRecord::Migration
	def self.up
		add_column :players, :is_operator, :boolean, :null => false, :default => false
	end

	def self.down
		remove_column :players, :is_operator
	end
end
