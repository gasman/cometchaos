class PlayerObserver < ActiveRecord::Observer
	
	def add_observer(obj)
		@observers ||= []
		@observers << obj
	end

	def delete_observer(obj)
		@observers.delete obj if @observers
	end

	def after_create(player)
		(@observers || []).each do |ob|
			ob.after_create_player(player) if ob.respond_to?(:after_create_player)
		end
	end

	def after_update(player)
		(@observers || []).each do |ob|
			ob.after_update_player(player) if ob.respond_to?(:after_update_player)
		end
	end

	def after_save(player)
		(@observers || []).each do |ob|
			ob.after_save_player(player) if ob.respond_to?(:after_save_player)
		end
	end

	def after_destroy(player)
		(@observers || []).each do |ob|
			ob.after_destroy_player(player) if ob.respond_to?(:after_destroy_player)
		end
	end

	def after_choose_spell(player)
		(@observers || []).each do |ob|
			ob.after_player_chooses_spell(player) if ob.respond_to?(:after_player_chooses_spell)
		end
	end

	def on_begin_turn(player)
		(@observers || []).each do |ob|
			ob.on_player_begin_turn(player) if ob.respond_to?(:on_player_begin_turn)
		end
	end

	def on_end_turn(player)
		(@observers || []).each do |ob|
			ob.on_player_end_turn(player) if ob.respond_to?(:on_player_end_turn)
		end
	end
end
