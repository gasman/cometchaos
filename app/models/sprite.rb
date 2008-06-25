class Sprite < ActiveRecord::Base
	belongs_to :player
	
	DISTANCES = [
		[9,9,9,9,9,9,6,9,9,9,9,9,9],
		[9,9,9,9,6,5,5,5,6,9,9,9,9],
		[9,9,6,5,5,4,4,4,5,5,6,9,9],
		[9,9,5,4,4,3,3,3,4,4,5,9,9],
		[9,6,5,4,3,2,2,2,3,4,5,6,9],
		[9,5,4,3,2,1,1,1,2,3,4,5,9],
		[6,5,4,3,2,1,0,1,2,3,4,5,6],
		[9,5,4,3,2,1,1,1,2,3,4,5,9],
		[9,6,5,4,3,2,2,2,3,4,5,6,9],
		[9,9,5,4,4,3,3,3,4,4,5,9,9],
		[9,9,6,5,5,4,4,4,5,5,6,9,9],
		[9,9,9,9,6,5,5,5,6,9,9,9,9],
		[9,9,9,9,9,9,6,9,9,9,9,9,9],
	]
	
	def game
		@game ||= player.game
	end
	
	def game_id
		game.id
	end
	
	def before_destroy
		# make sure we have a reference to @game cached before the association is lost
		game
	end
	
	def each_square_within(distance)
		(-6..6).each do |dy|
			(-6..6).each do |dx|
				x = self.x + dx
				y = self.y + dy
				next unless (0...Game::BOARD_WIDTH) === x and (0...Game::BOARD_HEIGHT) === y
				next if DISTANCES[dy+6][dx+6] > distance
				yield x,y
			end
		end	
	end
	
	def each_adjacent_square(&block)
		each_square_within(1, &block)
	end
	
	def neighbouring_enemies
		game.sprites.find(:all, :conditions => [
			# TODO: filter out dead sprites, etc
			'sprites.x >= ? AND sprites.x <= ? AND sprites.y >= ? AND sprites.y <= ?
			AND sprites.player_id <> ?',
			self.x - 1, self.x + 1, self.y - 1, self.y + 1, player_id])
	end
	
	def move_targets
		return {} if remaining_moves.nil? or remaining_moves == 0

		neighbouring_enemies = self.neighbouring_enemies
		if neighbouring_enemies.any?
			# TODO: exclude undead if this sprite isn't undead
			# TODO: omit engaged_to_enemy if this sprite is flying and enemy is >1 square away
			return {:sprites => neighbouring_enemies.collect(&:id), :engaged_to_enemy => true}
		else
			occupied_squares = game.sprites(true).collect{|sprite| [sprite.x, sprite.y]}
			available_squares = []
			each_adjacent_square do |x,y|
				available_squares << [x,y] unless occupied_squares.include?([x,y])
			end
			{:spaces => available_squares}
		end
	end
	
	def move!(x,y)
		x = x.to_i
		y = y.to_i
		raise Game::InvalidMove.new, "Out of range" unless remaining_moves and remaining_moves > 0
		raise Game::InvalidMove.new, "Out of range" unless move_targets[:spaces].include?([x,y])
		self.x = x
		self.y = y
		self.remaining_moves -= 1
		save!
	end
	
	def receive_attack
		callback :on_receive_attack
	end
	
	def die!
		# TODO: distinguish between real (change to corpse) and illusion/undead (delete)
		self.destroy
	end
	
	def attack!(target)
		raise Game::InvalidMove.new, "Out of range" unless move_targets[:sprites].include?(target.id)
		target.receive_attack
		# TODO: proper combat system
		if rand(2) > 0
			target.die!
			self.x = target.x
			self.y = target.y
		end
		self.remaining_moves -= 1
		save!
	end
end
