namespace :copy_old_history do
  desc 'Generate all'
  task base: :environment do
    CopyOldHistoryJob.run
  end

  task fred_copy: :environment do
    CopyFredHistoryJob.run
  end

  task fred_prepare_staging: :environment do
    CopyFredHistoryJob.run(prepare: true)
  end

  task all: :environment do
    Rake::Task['copy_old_history:base'].invoke
    Rake::Task['copy_old_history:fred_copy'].invoke
  end

  task clear: :environment do
    CopyOldHistoryJob::MODELS.each do |model|
      new_klass = "Audit::#{model}History".constantize
      new_klass.in_batches(&:delete_all)
    end
  end
end
