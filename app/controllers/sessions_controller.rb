# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
	# render new.rhtml
	def new
	end

	def create
		self.current_user = User.authenticate(params[:login], params[:password])
		if logged_in?
			if params[:remember_me] == "1"
				current_user.remember_me unless current_user.remember_token?
				cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
			end

			redirect_back_or_default('/')
		else
			render :action => 'new'
		end
	end

	def destroy
		# forget all games currently being played
		session[:games] = {}
		
		self.current_user.forget_me if logged_in?
		cookies.delete :auth_token
		reset_session
		redirect_back_or_default('/')
	end
end
