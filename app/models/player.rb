class Player < ActiveRecord::Base
	belongs_to :game
	has_many :spells, :class_name => 'Spells::Spell', :include => :spell_variety
	acts_as_list :scope => :game
	
	has_many :sprites, :dependent => :destroy
	
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
	
	def initialize(*opts)
		super(*opts)
		self.wizard_sprite = Sprite.new(:player => self,
			:image => "wizards/#{@wizard_type}_#{@wizard_colour}.png",
			:is_wizard => true, :movement_allowance => 1)
	end

	def wizard_sprite=(sprite)
		sprites << sprite
		@wizard_sprite = sprite
	end
	def wizard_sprite
		@wizard_sprite ||= sprites.detect(&:is_wizard?)
	end
	
	def before_update
		if name_changed? # TODO: check for avatar changing (once that's a field of player)
			callback :on_change_appearance
		end

		if is_operator_changed?
			callback(is_operator? ? :on_assign_operator : :on_revoke_operator)
		end
	end
	
	def awaiting_action?
		state == :choosing_spells || state == :casting || state == :fighting
	end
	
	def choose_spell!(spell)
		raise Game::InvalidMove.new, "You have already chosen a spell" if has_chosen_spell?
		raise Game::InvalidMove.new, "You cannot choose a spell at this time" unless game.choosing_spells?
		raise Game::InvalidMove.new, "That spell isn't yours!" unless spell.player == self
		self.next_spell = spell
		end_turn
		callback :after_choose_spell
	end
	
	# not intended to be called directly; game will call this when it's this player's turn,
	# to trigger callbacks
	def begin_casting
		callback :on_begin_casting
	end
	def begin_fighting
		callback :on_begin_fighting
	end
	
	# this IS intended to be called directly to end the user's turn -
	# either by user's explicit action to end turn, or after user's action has caused
	# the turn to end (e.g. having chosen / cast a spell).
	def end_turn
		case state
			when :choosing_spells
				self.has_chosen_spell = true
				save!
				game.continue!
				callback :on_end_choosing_spells
			when :casting
				game.next_player!
				callback :on_end_casting
			when :fighting
				game.next_player!
				callback :on_end_fighting
			else
				raise Game::InvalidMove.new, "It isn't currently your turn"
		end
	end
	
	STATES = [:nonplayer, :waiting, :choosing_spells, :casting, :fighting]
	def state
		if !game then :nonplayer
		# elsif self.dead? then :waiting # TODO: add this when we have a 'dead' status
		elsif game.choosing_spells? and !self.has_chosen_spell then :choosing_spells
		elsif game.casting? and game.current_player == self then :casting
		elsif game.fighting? and game.current_player == self then :fighting
		else :waiting
		end
	end
	
	# define state-testing methods: casting? etc
	STATES.each do |state_to_test|
		define_method "#{state_to_test}?" do
			self.state == state_to_test
		end
	end
	
	def cast_at_space!(x, y)
		x = x.to_i
		y = y.to_i
		raise Game::InvalidMove.new, "You cannot cast a spell at this time" unless casting?
		raise Game::InvalidMove.new, "Out of range" unless (next_spell.casting_targets[:spaces] || []).include?([x,y])
		next_spell.cast_at_space!(x,y)
		# TODO: don't discard spell / end turn if there are still shots remaining
		self.next_spell = nil
		save!
		end_turn
	end
	def cast_at_sprite!(sprite)
		raise Game::InvalidMove.new, "You cannot cast a spell at this time" unless casting?
		raise Game::InvalidMove.new, "Out of range" unless (next_spell.casting_targets[:sprites] || []).include?(sprite.id)
		next_spell.cast_at_sprite!(sprite)
		# TODO: don't discard spell / end turn if there are still shots remaining
		self.next_spell = nil
		save!
		end_turn
	end
end
