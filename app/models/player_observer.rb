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
end
