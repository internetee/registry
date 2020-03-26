namespace :copy_old_history do
  desc 'Generate all'
  task all: :environment do
    CopyOldHistoryJob.enqueue(run_at: 30.seconds.from_now, priority: 10)
  end
end
