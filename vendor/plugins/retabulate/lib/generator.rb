if File.basename($0) =~ /generate/
	require 'rails_generator'
	
	module Rails
		module Generator
			module Commands
				class Create
					private
					
					alias render_file_without_retabulation render_file
				
					# pass the output of render_file through the retabulate function
					# if it's one of the recognised file types
					def render_file(path, options = {}, &block)
						out = render_file_without_retabulation(path, options, &block)
						if path =~ Retabulate::CONVERTABLE_FILETYPES
							out = Retabulate::retabulate(out)
						end
	
						out
					end
				end
			end
		end
	end
end
