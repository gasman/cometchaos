# Retabulate

module Retabulate
	CONVERTABLE_FILETYPES = /(Rakefile|\.rb|\.html.erb|\.css|\.js)$/

	TAB_WIDTH = 2
	
	# Replaces any spaces in the leading whitespace of text lines with the appropriate number of tabs instead
	def self.retabulate(s)
		s.gsub(/^(\s+)/) do |whitespace|
			whitespace.gsub(' ' * TAB_WIDTH, "\t")
		end
	end
end
