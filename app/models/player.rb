class Player < ActiveRecord::Base
	belongs_to :game
	acts_as_list :scope => :game
	
	has_many :sprites
	has_one :wizard_sprite, :class_name => 'Sprite', :conditions => "is_wizard = 't'"

	validates_presence_of :name
end
