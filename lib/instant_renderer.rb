class InstantRenderer
	def initialize(url_opts)
		@url_opts = url_opts
		@av = ActionView::Base.new("#{RAILS_ROOT}/app/views")
		@av.controller = self
	end

	def url_for(options = nil)
		case options || {}
			when String
				options
			when Hash
				options.delete(:only_path)
				ActionController::Routing::Routes.generate(options, @url_opts)
			else
				polymorphic_url(options)
		end
	end
	
	def render(template, locals)
		@av.render_file(template, true, locals)
	end
end
