require File.expand_path(File.dirname(__FILE__) + "/../lib/retabulate")
require 'find'

desc "Convert all ruby / erb files to tab indentation"
task :retab do

	Find.find('.') do |path|
		if FileTest.file?(path) && path =~ Retabulate::CONVERTABLE_FILETYPES
			file_content = File.read(path)
			retabulated_file_content = Retabulate::retabulate file_content
			unless file_content == retabulated_file_content
				File.open(path, 'w') do |f|
					f.write(retabulated_file_content)
				end
				puts path
			end
		end
	end
	
end
