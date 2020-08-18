# This file is used by Rack-based servers to start the application.

require_relative 'config/environment'
run Rails.application

# turn automatic que temp off
# if defined?(PhusionPassenger)
  # PhusionPassenger.on_event(:starting_worker_process) do |forked|
    # if forked
      # Que.mode = :async
    # end
  # end
# end
