# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
	def stylesheet(*files)
		@stylesheets ||= []
		@stylesheets += files
	end

	def javascript(*files)
		@javascripts ||= []
		@javascripts += files
	end
end
