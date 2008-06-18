class GameObserver < ActiveRecord::Observer

	observe Game, Player, Sprite, Spells::Spell
	
	def add_observer(obj, game)
		@observers ||= {}
		@observers[game.id] ||= []
		@observers[game.id] << obj
	end

	def delete_observer(obj, game)
		@observers[game.id].delete obj if @observers and @observers[game.id]
	end

	def respond_to?(method)
		true
	end
	def method_missing(event, obj)
		((@observers && @observers[obj.game_id]) || []).each do |observer|
			if obj.is_a?(Spells::Spell)
				class_name = :spell # avoid indexing them under the name of their subclass
			else
				class_name = obj.class.name.underscore.to_sym
			end
			observer.receive_event(class_name, event, obj)
		end
	end
end
