class Game < ActiveRecord::Base

	class InvalidMove < RuntimeError; end

	acts_as_state_machine :initial => :open
	
	MAX_PLAYERS = 8
	WIZARD_START_POSITIONS = [
		[],
		[[1,4]],
		[[1,4],[13,4]],
		[[1,8],[7,1],[13,8]],
		[[1,8],[1,1],[13,1],[13,8]],
		[[3,9],[0,3],[7,0],[14,3],[11,9]],
		[[0,8],[0,1],[7,0],[14,1],[14,8],[7,9]],
		[[4,9],[0,6],[1,1],[7,0],[13,1],[14,6],[10,9]],
		[[0,9],[0,4],[0,0],[7,0],[14,0],[14,4],[14,9],[7,9]]
	]
	BOARD_WIDTH = 15
	BOARD_HEIGHT = 10
	
	has_many :players, :order => 'position'
	has_many :players_with_spells_to_cast, :class_name => 'Player', :conditions => "next_spell_id IS NOT NULL", :order => 'position'
	has_many :operators, :class_name => 'Player', :conditions => "is_operator = 't'"
	has_many :sprites, :through => :players
	belongs_to :current_player, :class_name => 'Player', :foreign_key => 'current_player_id'
	# TODO: protect some of these from mass-assignment
	
	# state machine behaviour
	state :open, :exit => :game_start_actions
	state :choosing_spells, :enter => :begin_choosing_spells
	state :casting, :enter => :begin_casting
	state :fighting, :enter => :begin_fighting
	
	event :start do
		transitions :from => :open, :to => :choosing_spells
	end
	event :continue do
		transitions :from => :choosing_spells, :to => :casting, :guard => lambda {|game| game.players.all?(&:has_chosen_spell?) }
		transitions :from => :casting, :to => :fighting, :guard => lambda {|game| game.players_with_spells_to_cast(true).empty? }
		transitions :from => :fighting, :to => :choosing_spells, :guard => lambda {|game| game.current_player == game.players.last }
	end
	
	# to facilitate observing all objects relating to a specific game
	def game_id
		self.id
	end
	
	# Comet communication
	def channel
		"game_#{self.id}"
	end
	
	def broadcast(message)
		Meteor.shoot self.channel, message
	end
	
	def self.all_active_public
		find(:all, :conditions => "games.is_public = 't' AND players.id IS NOT NULL", :include => :operators)
	end
	
	def joinable?
		self.open? and players.size < MAX_PLAYERS
	end

	def startable?
		self.open? and players.size > 1
	end
	
	def add_player(player)
		# we can't simply run set_wizard_start_positions on the players collection after
		# appending the new player, because that will return a new instance of player,
		# and consequently a new instance of sprite, and therefore the old instance of
		# sprite will be sitting around in the observer's queue with no coordinates.
		# Activerecord == fail.
		set_wizard_start_positions(players + [player])
		players << player
		callback :become_unjoinable if players.size == MAX_PLAYERS
		callback :become_startable if players.size == 2
	end

	def remove_player(player)
		players.delete(player)
		player.destroy
		if open?
			set_wizard_start_positions(players)
			callback :become_joinable if players.size == MAX_PLAYERS - 1
			callback :become_unstartable if players.size == 1
		else
			# the departure of a player might make it possible to move to the next game
			# state - for example, if they were the last player left to choose a spell
			game.continue!
		end
	end
	
	def next_player!
		if self.casting?
			next_player = players_with_spells_to_cast.find(:first,
				:conditions => ['position > ?', current_player.position])
			if next_player
				self.current_player = next_player
				save!
				self.current_player.begin_casting
			else
				# all players have cast spells
				self.continue!
			end
		elsif self.fighting?
			next_player = players.find(:first,
				:conditions => ['position > ?', current_player.position])
			if next_player
				self.current_player = next_player
				save!
				self.current_player.begin_fighting
			else
				# all players have completed combat
				self.continue!
			end
		else
			raise InvalidMove.new, "Game is not currently in a turn-based phase"
		end
	end
	
	def sprites_by_location
		result = {}
		sprites.each do |sprite|
			result[[sprite.x, sprite.y]] = sprite
		end
		result
	end
	
	private
	
	def set_wizard_start_positions(players)
		starts = WIZARD_START_POSITIONS[players.size]
		players.each_with_index do |player, i|
			player.wizard_sprite.attributes = {:x => starts[i][0], :y => starts[i][1]}
			player.wizard_sprite.save! unless player.wizard_sprite.new_record?
		end
	end
	
	def game_start_actions
		distribute_spells
		callback :on_start
	end
	
	def distribute_spells
		persistent_spell_varieties = SpellVariety.find(:all,
			:conditions => "is_persistent = 't'")
		spell_varieties_in_rotation = SpellVariety.find(:all,
			:conditions => "is_in_rotation = 't'")

		players.each do |player|
			# provide one each of the persistent spell types
			player.spells << persistent_spell_varieties.collect{|variety| variety.instantiate}
			# and between 12 and 15 of the others
			(12 + rand(4)).times do
				player.spells << spell_varieties_in_rotation.rand.instantiate
			end
		end
	end
	
	def begin_choosing_spells
		self.players.each do |player|
			player.update_attribute(:has_chosen_spell, false)
			player.update_attribute(:next_spell_id, nil)
		end
		callback :on_begin_choosing_spells
	end
	
	def begin_casting
		if players_with_spells_to_cast.any?
			self.current_player = players_with_spells_to_cast.first
			save!
			self.current_player.begin_casting
		else
			continue!
		end
		change_state_actions
	end

	def begin_fighting
		# need to reload sprites association, because a sprite may have been added
		# outside of the game model in this current request
		sprites(true).each do |sprite|
			sprite.update_attribute(:remaining_moves, sprite.movement_allowance)
		end
		self.current_player = players.first
		save!
		self.current_player.begin_fighting
		change_state_actions
	end
	
	# TODO: deprecate
	def change_state_actions
		callback :on_state_change
	end
end
