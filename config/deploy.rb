# Application
set :application, "chaos"
set :deploy_to, "/var/www/#{application}"

# Settings
default_run_options[:pty] = true
set :use_sudo, false

# Servers
set :user, "root"
set :domain, "chaos.zxdemo.org"
server "altaria.vm.bytemark.co.uk", :app, :web
role :db, "altaria.vm.bytemark.co.uk", :primary => true

# Subversion
set :repository,  "http://svn.matt.west.co.tt/svn/chaos/trunk/"
set :checkout, "export"

# Passenger
namespace :deploy do
	desc "Restarting mod_rails with restart.txt"
	task :restart, :roles => :app, :except => { :no_release => true } do
		run "touch #{current_path}/tmp/restart.txt"
	end

	[:start, :stop].each do |t|
		desc "#{t} task is a no-op with mod_rails"
		task t, :roles => :app do ; end
	end
end
