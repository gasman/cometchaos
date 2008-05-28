set :application, "chaos"
set :repository,  "http://svn.matt.west.co.tt/svn/chaos/trunk/"

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
set :deploy_to, "/var/www/#{application}"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion

role :app, "altaria.vm.bytemark.co.uk"
role :web, "altaria.vm.bytemark.co.uk"
role :db,  "altaria.vm.bytemark.co.uk", :primary => true
