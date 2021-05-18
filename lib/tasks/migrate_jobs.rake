namespace :migrate_jobs do
  task all: :environment do
    QueJob.all.each do |job|
      process_que_job(job)
    end
  end

  task first: :environment do
    job = QueJob.first
    process_que_job(job)
  end

  def process_que_job(que_job)
    return unless que_job

    if skip_condition(que_job)
      puts "Skipped Que job migration: #{que_job.inspect}"
    else
      args = que_job.args
      time = que_job.run_at

      que_job.job_class.constantize.set(wait_until: time).perform_later(args)
    end
  end

  def skip_condition(que_job)
    que_job.last_error.present? || !(que_job.job_class.constantize < ApplicationJob)
  end
end
