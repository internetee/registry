require 'mina/bundler'
require 'mina/rails'
require 'mina/git'
require 'mina/whenever'
require 'mina/rbenv'  # for rbenv support. (http://rbenv.org)
# require 'mina/rvm'    # for rvm support. (http://rvm.io)

# Basic settings:
#   domain       - The hostname to SSH to.
#   deploy_to    - Path to deploy into.
#   repository   - Git repo to clone from. (needed by mina/git)
#   branch       - Branch name to deploy. (needed by mina/git)

# alpha branch
set :domain, 'registry-st'
set :deploy_to, '$HOME/registry'
set :repository, 'https://github.com/domify/registry' # dev repo
set :branch, 'master'
set :rails_env, 'alpha'
set :delayed_job, true

# alpha branch
task :epp do
  set :domain, 'registry-st'
  set :deploy_to, '$HOME/epp'
  set :repository, 'https://github.com/domify/registry' # dev repo
  set :branch, 'master'
  set :rails_env, 'alpha'
  set :delayed_job, false
end

task :registrar do
  set :domain, 'registry-st'
  set :deploy_to, '$HOME/registrar'
  set :repository, 'https://github.com/domify/registry' # dev repo
  set :branch, 'master'
  set :rails_env, 'alpha'
  set :delayed_job, false
end

# staging
task :st do
  set :domain, 'registry-st'
  set :deploy_to, '$HOME/registry'
  set :repository, 'https://github.com/internetee/registry' # production repo
  set :branch, 'master' # same as production
  set :rails_env, 'staging'
  set :delayed_job, true
end

# staging
task :eppst do
  set :domain, 'epp-st'
  set :deploy_to, '$HOME/epp'
  set :repository, 'https://github.com/internetee/registry' # production repo
  set :branch, 'master' # same as production
  set :rails_env, 'staging'
  set :delayed_job, false
end

# staging
task :registrarst do
  set :domain, 'registrar-st'
  set :deploy_to, '$HOME/registrar'
  set :repository, 'https://github.com/internetee/registry' # production repo
  set :branch, 'master'
  set :rails_env, 'staging'
  set :delayed_job, false
end

# production
task :pr do
  set :domain, 'registry'
  set :deploy_to, '$HOME/registry'
  set :repository, 'https://github.com/internetee/registry' # production repo
  set :branch, 'master' # same as staging
  set :rails_env, 'production'
  set :delayed_job, true
end

# production
task :epppr do
  set :domain, 'epp'
  set :deploy_to, '$HOME/epp'
  set :repository, 'https://github.com/internetee/registry' # production repo
  set :branch, 'master' # same as staging
  set :rails_env, 'production'
  set :delayed_job, false
end

# production
task :registrarst do
  set :domain, 'registrar'
  set :deploy_to, '$HOME/registrar'
  set :repository, 'https://github.com/internetee/registry' # production repo
  set :branch, 'master'
  set :rails_env, 'production'
  set :delayed_job, false
end

# Manually create these paths in shared/ (eg: shared/config/database.yml) in your server.
# They will be linked in the 'deploy:link_shared_paths' step.
set :shared_paths, [
  'config/application.yml',
  'config/database.yml',
  'config/initializers/current_commit_hash.rb',
  'log',
  'public/system',
  'export/zonefiles'
]

# Optional settings:
#   set :user, 'foobar'    # Username in the server to SSH to.
#   set :port, '30000'     # SSH port number.

# This task is the environment that is loaded for most commands, such as
# `mina deploy` or `mina rake`.
task :environment do
  # Be sure to commit your .ruby-version to your repository.
  invoke :'rbenv:load'
end

# Put any custom mkdir's in here for when `mina setup` is ran.
# For Rails apps, we'll make some of the shared paths that are shared between
# all releases.
task setup: :environment do
  queue! %(mkdir -p "#{deploy_to}/shared/log")
  queue! %(chmod g+rx,u+rwx "#{deploy_to}/shared/log")

  queue! %(mkdir -p "#{deploy_to}/shared/config")
  queue! %(chmod g+rx,u+rwx "#{deploy_to}/shared/config")

  queue! %(mkdir -p "#{deploy_to}/shared/config/initializers")
  queue! %(chmod g+rx,u+rwx "#{deploy_to}/shared/config/initializers")

  queue! %(mkdir -p "#{deploy_to}/shared/public")
  queue! %(chmod g+rx,u+rwx "#{deploy_to}/shared/public")

  queue! %(mkdir -p "#{deploy_to}/shared/public/system")
  queue! %(chmod g+rx,u+rwx "#{deploy_to}/shared/public/system")

  queue! %(mkdir -p "#{deploy_to}/shared/export/zonefiles")
  queue! %(chmod g+rx,u+rwx "#{deploy_to}/shared/export/zonefiles")

  queue! %(touch "#{deploy_to}/shared/config/database.yml")
  deploy do
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    to :launch do
      queue! 'gem install bundler'
      invoke :'bundle:install'
      queue %(echo '\n  NB! Please edit 'shared/config/database.yml'\n')
    end
  end
end

desc 'Deploys the current version to the server.'
task deploy: :environment do
  deploy do
    # Put things that will set up an empty directory into a fully set-up
    # instance of your project.
    to :prepare do
      invoke :'delayed_job:stop' if delayed_job
    end

    invoke :'git:clone'
    invoke :load_commit_hash
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'rails:db_migrate'
    invoke :'rails:assets_precompile'
    to :launch do
      invoke :restart
      invoke :'delayed_job:start' if delayed_job
    end
  end
end

desc 'Rolls back the latest release'
task rollback: :environment do
  queue! %(echo "-----> Rolling back to previous release for instance: #{domain}")
  queue %(ls "#{deploy_to}/releases" -Art | sort | tail -n 2 | head -n 1)
  queue! %(
    ls -Art "#{deploy_to}/releases" | sort | tail -n 2 | head -n 1 |
    xargs -I active ln -nfs "#{deploy_to}/releases/active" "#{deploy_to}/current"
  )
  to :launch do
    invoke :restart
  end
end

desc 'Loads current commit hash'
task load_commit_hash: :environment do
  queue! %(
    echo "CURRENT_COMMIT_HASH = '$(git --git-dir #{deploy_to}/scm rev-parse --short HEAD)'" > \
    #{deploy_to}/shared/config/initializers/current_commit_hash.rb
  )
end

namespace :delayed_job do
  task stop: :environment do
    queue %(echo "-----> Stopping delayed job"; cd #{deploy_to}/current; RAILS_ENV=#{rails_env} bin/delayed_job stop)
  end

  task start: :environment do
    queue %(echo "-----> Starting delayed job"; cd #{deploy_to}/current; RAILS_ENV=#{rails_env} bin/delayed_job start)
  end
end

desc 'Restart Passenger application'
task restart: :environment do
  queue "mkdir -p #{deploy_to}/current/tmp; touch #{deploy_to}/current/tmp/restart.txt"
end

namespace :cron do
  desc 'Setup cron tasks.'
  task setup: :environment do
    invoke :'rbenv:load'
    invoke :'whenever:update'
  end

  desc 'Clear cron tasks.'
  task clear: :environment do
    invoke :'rbenv:load'
    invoke :'whenever:clear'
  end
end

# For help in making your deploy script, see the Mina documentation:
#
#  - http://nadarei.co/mina
#  - http://nadarei.co/mina/tasks
#  - http://nadarei.co/mina/settings
#  - http://nadarei.co/mina/helpers
