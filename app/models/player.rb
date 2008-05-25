class Player < ActiveRecord::Base
	belongs_to :game
	acts_as_list :scope => :game
	
	has_many :sprites
	has_one :wizard_sprite, :class_name => 'Sprite', :conditions => "is_wizard = 't'"

	validates_presence_of :name
	
	def after_create
		self.wizard_sprite = Sprite.new(:image => 'wizards/pointer.png', :is_wizard => true)
		game.set_wizard_start_positions
	end
end
