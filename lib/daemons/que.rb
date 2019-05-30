#!/usr/bin/env ruby

ENV['RAILS_ENV'] ||= 'production'

root = __dir__
root = File.dirname(root) until File.exist?(File.join(root, 'config'))
Dir.chdir(root)

require File.join(root, 'config', 'environment')

# from que gem rake task
if defined?(::Rails) && Rails.respond_to?(:application)
  # ActiveSupport's dependency autoloading isn't threadsafe, and Que uses
  # multiple threads, which means that eager loading is necessary. Rails
  # explicitly prevents eager loading when the environment task is invoked,
  # so we need to manually eager load the app here.
  Rails.application.eager_load!
end

Que.logger.level  = Logger.const_get((ENV['QUE_LOG_LEVEL'] || 'INFO').upcase)
Que.worker_count  = 1
Que.wake_interval = (ENV['QUE_WAKE_INTERVAL'] || 1).to_f
Que.mode          = :async

# When changing how signals are caught, be sure to test the behavior with
# the rake task in tasks/safe_shutdown.rb.

stop = false
%w[INT].each do |signal|
  trap(signal) { stop = true }
end

at_exit do
  $stdout.puts "Finishing Que's current jobs before exiting..."
  Que.worker_count = 0
  Que.mode = :off
  $stdout.puts "Que's jobs finished, exiting..."
end

loop do
  sleep 1
  break if stop
end
