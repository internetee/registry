class MigrateQueJobs < ActiveRecord::Migration[6.0]
  def up
    QueJob.all.each do |job|
      next if job.last_error.present?

      klass = job.job_class.constantize
      next unless klass < ApplicationJob

      args = job.args
      klass.perform_later(args)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
