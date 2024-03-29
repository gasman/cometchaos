namespace :spells do
	desc "Load spells list from spells.csv"
	task :load => :environment do
		require 'fastercsv'
		FasterCSV.parse(File.open(File.join(RAILS_ROOT, 'db', 'spells.csv')), :headers => true) do |row|
			spell = SpellVariety.find_by_id(row['id'])
			if spell.nil?
				spell = SpellVariety.new
				spell.id = row['id']
			end
			spell.attributes = row.to_hash
			spell.save!
		end
	end
end
