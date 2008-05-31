class AddMovementAllowance < ActiveRecord::Migration
	def self.up
		add_column :sprites, :movement_allowance, :integer
		add_column :sprites, :remaining_moves, :integer
		add_column :spell_types, :movement_allowance, :integer
	end

	def self.down
		remove_column :sprites, :movement_allowance
		remove_column :sprites, :remaining_moves
		remove_column :spell_types, :movement_allowance
	end
end
