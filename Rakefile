# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'
require 'yard'

YARD::Rake::YardocTask.new do |t|
  t.files   = ['app/**/*.rb']   # optional
end

Rails.application.load_tasks
