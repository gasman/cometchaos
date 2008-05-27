class Spell < ActiveRecord::Base
	belongs_to :player
	belongs_to :spell_type, :class_name => 'SpellTypes::SpellType'

	delegate :name, :to => :spell_type
end
