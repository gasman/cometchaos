class Player < ActiveRecord::Base
	belongs_to :game
	acts_as_list :scope => :game
	
	has_many :sprites, :dependent => :destroy
	has_one :wizard_sprite, :class_name => 'Sprite', :conditions => "is_wizard = 't'"
	
	WIZARD_TYPES = %w(pointer snooker treetrunk molotov elvis nightie ghostie sticky)
	WIZARD_COLOURS = %w(red magenta green cyan gold yellow grey white)
	attr_accessor :wizard_type, :wizard_colour

	validates_presence_of :name
	validates_presence_of :game	
	# the Rails documentation says I should be validating game_id instead, because
	# game may not have been set if the association was made some other way besides
	# the belongs_to association (such as game.players << player). But then it
	# won't work *at all* if game is a new record.
	# The Rails documentation can bite me.
	validates_inclusion_of :wizard_type, :in => WIZARD_TYPES
	validates_inclusion_of :wizard_colour, :in => WIZARD_COLOURS
	
	def after_create
		self.wizard_sprite = Sprite.new(:image => "wizards/#{@wizard_type}_#{@wizard_colour}.png", :is_wizard => true)
		game.set_wizard_start_positions
	end
end
