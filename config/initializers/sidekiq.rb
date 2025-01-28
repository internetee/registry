require 'sidekiq/web' # Require at the top of the initializer

Sidekiq.configure_server do |config|
  config.logger.level = Logger::INFO
  
  # Custom job logging format
  Sidekiq.logger.formatter = proc do |severity, datetime, progname, msg|
    thread_id = Thread.current.object_id.to_s(36)
    process_id = Process.pid

    # Skip messages containing "start" or "Performed"
    next nil if msg.to_s == 'start' || msg.to_s.include?('Performed')

    # Skip "fail" message as we'll get detailed error after
    next nil if msg.to_s == 'fail'

    # Store job info when job starts
    if msg.to_s.start_with?('Performing')
      Thread.current[:current_job_info] = msg.to_s
    end

    # Add job info to done message
    if msg.to_s == 'done' && Thread.current[:current_job_info]
      job_info = Thread.current[:current_job_info].sub('Performing', 'Completed')
      msg = job_info
    end

    "#{datetime.utc.iso8601(3)} pid=#{process_id} tid=#{thread_id} #{severity}: #{msg}\n"
  end
end

# Client configuration (if needed)
Sidekiq.configure_client do |config|
  config.logger.level = Logger::INFO
end
