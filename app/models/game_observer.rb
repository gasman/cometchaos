class GameObserver < ActiveRecord::Observer
	
	def add_observer(obj)
		@observers ||= []
		@observers << obj
	end

	def delete_observer(obj)
		@observers.delete obj if @observers
	end

	def after_create(game)
		@observers.each do |ob|
			ob.after_create_game(game) if ob.respond_to?(:after_create_game)
		end
	end

	def after_update(game)
		@observers.each do |ob|
			ob.after_update_game(game) if ob.respond_to?(:after_update_game)
		end
	end

	def after_save(game)
		@observers.each do |ob|
			ob.after_save_game(game) if ob.respond_to?(:after_save_game)
		end
	end
	
	def on_start(game)
		@observers.each do |ob|
			ob.on_start_game(game) if ob.respond_to?(:on_start_game)
		end
	end
end
