worker_processes 2

after_fork do |server, worker|
  ActiveRecord::Base.establish_connection

  Que.mode = :async
end
