# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'

if Rails.env == 'development'
  require 'yard'

  YARD::Rake::YardocTask.new do |t|
    # t.files   = ['app/**/*.rb', 'lib/**/*.rake']   # optional
  end
end

Rails.application.load_tasks
