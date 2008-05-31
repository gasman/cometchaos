class Sprite < ActiveRecord::Base
	belongs_to :player
	
	def game
		@game ||= player.game
	end
	
	def before_destroy
		# make sure we have a reference to @game cached before the association is lost
		game
	end
	
	def each_adjacent_square
		(self.x - 1).upto(self.x + 1) do |x|
			(self.y - 1).upto(self.y + 1) do |y|
				next unless (0...Game::BOARD_WIDTH) === x and (0...Game::BOARD_HEIGHT) === y
				yield x,y
			end
		end
	end
	
	def move_positions
		return [] if remaining_moves.nil? or remaining_moves == 0

		occupied_squares = game.sprites(true).collect{|sprite| [sprite.x, sprite.y]}
		available_squares = []
		each_adjacent_square do |x,y|
			available_squares << [x,y] unless occupied_squares.include?([x,y])
		end
		available_squares
	end
	
	def move!(x,y)
		x = x.to_i
		y = y.to_i
		raise Game::InvalidMove.new, "Out of range" unless remaining_moves and remaining_moves > 0
		raise Game::InvalidMove.new, "Out of range" unless move_positions.include?([x,y])
		self.x = x
		self.y = y
		self.remaining_moves -= 1
		save!
	end
end
