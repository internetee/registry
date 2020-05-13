namespace :copy_old_history do
  desc 'Generate all'
  task all: :environment do
    CopyOldHistoryJob.run
  end

  task copy_fred: :environment do
    CopyOldHistoryJob.run
  end

  task clear: :environment do
    CopyOldHistoryJob::MODELS.each do |model|
      new_klass = "Audit::#{model}History".constantize
      new_klass.in_batches(&:delete_all)
    end
  end
end
