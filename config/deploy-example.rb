require 'mina/bundler'
require 'mina/rails'
require 'mina/git'
require 'mina/rbenv'  # for rbenv support. (http://rbenv.org)

# Basic settings:
#   domain       - The hostname to SSH to.
#   deploy_to    - Path to deploy into.
#   repository   - Git repo to clone from. (needed by mina/git)
#   branch       - Branch name to deploy. (needed by mina/git)

# alpha branch, all interfaces unified
set :domain, 'registry'
set :deploy_to, '$HOME/registry'
set :repository, 'https://github.com/domify/registry' # dev repo
set :branch, 'master'
set :rails_env, 'alpha'
set :que_restart, true
set :cron_group, 'registry'

# alpha branch, only use for heavy debugging
task :epp do
  set :domain, 'registry'
  set :deploy_to, '$HOME/epp'
  set :repository, 'https://github.com/domify/registry' # dev repo
  set :branch, 'master'
  set :rails_env, 'alpha'
  set :que_restart, false
end

# alpha branch, only use for heavy debugging
task :registrar do
  set :domain, 'registry'
  set :deploy_to, '$HOME/registrar'
  set :repository, 'https://github.com/domify/registry' # dev repo
  set :branch, 'master'
  set :rails_env, 'alpha'
  set :que_restart, false
  set :cron_group, 'registrar'
end

# alpha branch, only use for heavy debugging
task :registrant do
  set :domain, 'registryt'
  set :deploy_to, '$HOME/registrant'
  set :repository, 'https://github.com/domify/registry' # dev repo
  set :branch, 'master'
  set :rails_env, 'alpha'
  set :que_restart, false
  set :cron_group, 'registrant'
end

# staging
task :st do
  set :domain, 'registry-st'
  set :deploy_to, '$HOME/registry'
  set :repository, 'https://github.com/internetee/registry' # production repo
  set :branch, 'staging'
  set :rails_env, 'staging'
  set :que_restart, true
end

# staging
task :eppst do
  set :domain, 'epp-st'
  set :deploy_to, '$HOME/epp'
  set :repository, 'https://github.com/internetee/registry' # production repo
  set :branch, 'staging'
  set :rails_env, 'staging'
  set :que_restart, false
  set :cron_group, 'epp'
end

# staging
task :registrarst do
  set :domain, 'registrar-st'
  set :deploy_to, '$HOME/registrar'
  set :repository, 'https://github.com/internetee/registry' # production repo
  set :branch, 'staging'
  set :rails_env, 'staging'
  set :que_restart, false
  set :cron_group, 'registrar'
end

# staging
task :registrantst do
  set :domain, 'registrant-st'
  set :deploy_to, '$HOME/registrant'
  set :repository, 'https://github.com/internetee/registry' # production repo
  set :branch, 'staging'
  set :rails_env, 'staging'
  set :que_restart, false
  set :cron_group, 'registrant'
end

# production
task :pr do
  set :domain, 'registry'
  set :deploy_to, '$HOME/registry'
  set :repository, 'https://github.com/internetee/registry' # production repo
  set :branch, 'master'
  set :rails_env, 'production'
  set :que_restart, true
end

# production
task :epppr do
  set :domain, 'epp'
  set :deploy_to, '$HOME/epp'
  set :repository, 'https://github.com/internetee/registry' # production repo
  set :branch, 'master'
  set :rails_env, 'production'
  set :que_restart, false
  set :cron_group, 'epp'
end

# production
task :registrarpr do
  set :domain, 'registrar'
  set :deploy_to, '$HOME/registrar'
  set :repository, 'https://github.com/internetee/registry' # production repo
  set :branch, 'master'
  set :rails_env, 'production'
  set :que_restart, false
  set :cron_group, 'registrar'
end

# production
task :registrantpr do
  set :domain, 'registrant'
  set :deploy_to, '$HOME/registrant'
  set :repository, 'https://github.com/internetee/registry' # production repo
  set :branch, 'master'
  set :rails_env, 'production'
  set :que_restart, false
  set :cron_group, 'registrant'
end

# Manually create these paths in shared/ (eg: shared/config/database.yml) in your server.
# They will be linked in the 'deploy:link_shared_paths' step.
set :shared_paths, [
  'config/application.yml',
  'config/database.yml',
  'config/initializers/current_commit_hash.rb',
  'log',
  'public/system',
  'public/assets',
  'export/zonefiles',
  'import/bank_statements',
  'import/legal_documents',
  'tmp/pids'
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

  queue! %(mkdir -p "#{deploy_to}/shared/public/assets")
  queue! %(chmod g+rx,u+rwx "#{deploy_to}/shared/public/assets")

  queue! %(mkdir -p "#{deploy_to}/shared/export/zonefiles")
  queue! %(chmod g+rx,u+rwx "#{deploy_to}/shared/export/zonefiles")

  queue! %(mkdir -p "#{deploy_to}/shared/import/bank_statements")
  queue! %(chmod g+rx,u+rwx "#{deploy_to}/shared/import/bank_statements")

  queue! %(mkdir -p "#{deploy_to}/shared/import/legal_documents")
  queue! %(chmod g+rx,u+rwx "#{deploy_to}/shared/import/legal_documents")

  queue! %(mkdir -p "#{deploy_to}/shared/log/que")
  queue! %(chmod g+rx,u+rwx "#{deploy_to}/shared/log/que")

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
    invoke :'git:clone'
    invoke :load_commit_hash

    # TEMP until all servers are updated
    queue! %(mkdir -p "#{deploy_to}/shared/log/que")
    queue! %(chmod g+rx,u+rwx "#{deploy_to}/shared/log/que")

    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'data_migration'
    invoke :'rails:db_migrate'
    invoke :'rails:assets_precompile'
    to :launch do
      invoke :restart
      invoke :'deploy:cleanup'
      invoke :que_restart if que_restart
    end
  end
end

# data_migrate=some_data_migration mina deploy env 
desc 'Run data migrations if any set with ENV[data_migrate]'
task data_migration: :environment do
        if ENV['data_migrate']
                queue! %(echo "Running data migration #{ENV['data_migrate']}")
                queue! %[cd #{current}]
                queue! %[bundle exec rake data_migrations:#{ENV['data_migrate']} RAILS_ENV=#{rails_env}]
        else
                puts "No data migration specified"
        end
end

desc 'Loads current commit hash'
task load_commit_hash: :environment do
  queue! %(
    echo "CURRENT_COMMIT_HASH = '$(git --git-dir #{deploy_to}/scm rev-parse --short #{branch})'" > \
    #{deploy_to}/shared/config/initializers/current_commit_hash.rb
  )
end

desc 'Restart Passenger application'
task restart: :environment do
  queue "mkdir -p #{deploy_to}/current/tmp; touch #{deploy_to}/current/tmp/restart.txt"
end

desc 'Restart que server'
task que_restart: :environment do
  queue "/etc/init.d/que restart"
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

namespace :whenever do
  name = -> { "#{domain}_#{rails_env}" }

  desc "Clear crontab"
  task clear: :environment  do
    queue %(
      echo "-----> Clear crontab for #{name.call}"
      #{echo_cmd %(cd #{deploy_to!}/#{current_path!} ; #{bundle_bin} exec whenever --clear-crontab #{name.call} --set 'environment=#{rails_env}&path=#{deploy_to!}/#{current_path!}&cron_group=#{cron_group}')}
    )
  end
  desc "Update crontab"
  task update: :environment do
    queue %(
      echo "-----> Update crontab for #{name.call}"
      #{echo_cmd %(cd #{deploy_to!}/#{current_path!} ; #{bundle_bin} exec whenever --update-crontab #{name.call} --set 'environment=#{rails_env}&path=#{deploy_to!}/#{current_path!}&cron_group=#{cron_group}')}
    )
  end
  desc "Write crontab"
  task write: :environment do
    queue %(
      echo "-----> Update crontab for #{name.call}"
      #{echo_cmd %(cd #{deploy_to!}/#{current_path!} ; #{bundle_bin} exec whenever --write-crontab #{name.call} --set 'environment=#{rails_env}&path=#{deploy_to!}/#{current_path!}&cron_group=#{cron_group}')}
    )
  end
end

# For help in making your deploy script, see the Mina documentation:
#
#  - http://nadarei.co/mina
#  - http://nadarei.co/mina/tasks
#  - http://nadarei.co/mina/settings
#  - http://nadarei.co/mina/helpers
