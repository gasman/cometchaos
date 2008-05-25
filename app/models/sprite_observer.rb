class SpriteObserver < ActiveRecord::Observer
	
	def add_observer(obj)
		@observers ||= []
		@observers << obj
	end

	def delete_observer(obj)
		@observers.delete obj if @observers
	end

	def after_create(sprite)
		(@observers || []).each do |ob|
			ob.after_create_sprite(sprite) if ob.respond_to?(:after_create_sprite)
		end
	end

	def after_update(sprite)
		(@observers || []).each do |ob|
			ob.after_update_sprite(sprite) if ob.respond_to?(:after_update_sprite)
		end
	end

	def after_save(sprite)
		(@observers || []).each do |ob|
			ob.after_save_sprite(sprite) if ob.respond_to?(:after_save_sprite)
		end
	end
end
