class MigrateQueJobs < ActiveRecord::Migration[6.0]
  def up
    QueJob.all.each do |job|
      if skip_condition(job)
        logger.info "Skipped Que job migration: #{job.inspect}"
      else
        args = job.args

        job.job_class.constantize.set(wait_until: job.run_at).perform_later(args)
      end
    end
  end

  def down
    # raise ActiveRecord::IrreversibleMigration
  end

  def logger
    @logger ||= Logger.new(Rails.root.join('log', 'que_to_sidekiq_migration.log'))
  end

  def skip_condition(job)
    job.last_error.present? || !(job.job_class.constantize < ApplicationJob)
  end
end
