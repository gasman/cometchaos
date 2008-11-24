class UsersController < ApplicationController
	before_filter :login_required, :only => :edit

	# render new.rhtml
	def new
	end

	def create
		cookies.delete :auth_token
		# protects against session fixation attacks, wreaks havoc with 
		# request forgery protection.
		# uncomment at your own risk
		# reset_session
		@user = User.new(params[:user])
		@user.save
		if @user.errors.empty?
			self.current_user = @user
			redirect_back_or_default('/')
		else
			render :action => 'new'
		end
	end
	
	def edit
		if request.post?
			current_user.attributes = params[:user]
			if current_user.save
				redirect_back_or_default('/')
			else
				@user = current_user
			end
		else
			@user = current_user
		end
	end

end
