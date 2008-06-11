class Player < ActiveRecord::Base
	belongs_to :game
	has_many :spells, :class_name => 'Spells::Spell', :include => :spell_variety
	acts_as_list :scope => :game
	
	has_many :sprites, :dependent => :destroy
	has_one :wizard_sprite, :class_name => 'Sprite', :conditions => "is_wizard = 't'"
	
	belongs_to :next_spell, :class_name => 'Spells::Spell', :foreign_key => 'next_spell_id'
	
	attr_protected :is_operator, :next_spell, :next_spell_id, :has_chosen_spell
	
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
	validates_inclusion_of :wizard_type, :in => WIZARD_TYPES, :if => :new_record?
	validates_inclusion_of :wizard_colour, :in => WIZARD_COLOURS, :if => :new_record?
	
	def after_create
		self.wizard_sprite = Sprite.new(:image => "wizards/#{@wizard_type}_#{@wizard_colour}.png",
			:is_wizard => true, :movement_allowance => 1)
		game.set_wizard_start_positions
	end
	
	def after_destroy
		game.set_wizard_start_positions
		# the departure of a player might make it possible to move to the next game
		# state - for example, if they were the last player left to choose a spell
		game.continue!
	end
	
	def awaiting_action?
		(game.choosing_spells? and !has_chosen_spell?) or
		(game.casting? and game.current_player == self) or
		(game.combat? and game.current_player == self)
	end
	
	def choose_spell!(spell)
		raise Game::InvalidMove.new, "You have already chosen a spell" if has_chosen_spell?
		raise Game::InvalidMove.new, "You cannot choose a spell at this time" unless game.choosing_spells?
		raise Game::InvalidMove.new, "That spell isn't yours!" unless spell.player == self
		self.next_spell = spell
		self.has_chosen_spell = true
		save!
		callback :after_choose_spell
	end
	
	# not intended to be called directly; game will call this when it's this player's turn,
	# to trigger callbacks
	def begin_turn
		callback :on_begin_turn
	end
	
	def end_turn
		game.next_player!
		callback :on_end_turn
	end
	
	def is_casting?
		game and game.casting? and game.current_player == self
	end
	def is_fighting?
		game and game.combat? and game.current_player == self
	end
	
	# coordinates where this player can cast his next spell
	def casting_positions
		raise Game::InvalidMove.new, "You cannot cast a spell at this time" unless is_casting?
		
		occupied_squares = game.sprites.collect{|sprite| [sprite.x, sprite.y]}
		available_squares = []
		
		wizard_sprite.each_adjacent_square do |x,y|
			available_squares << [x,y] unless occupied_squares.include?([x,y])
		end
		available_squares
	end
	
	def cast!(x, y)
		x = x.to_i
		y = y.to_i
		raise Game::InvalidMove.new, "You cannot cast a spell at this time" unless is_casting?
		raise Game::InvalidMove.new, "Out of range" unless casting_positions.include?([x,y])
		next_spell.cast!(x,y)
		self.next_spell = nil
		save!
		end_turn
	end
end
