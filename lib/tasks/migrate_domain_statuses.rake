namespace :migrate_domain_statuses do
  desc 'Starts collect invalid validation contacts'
  task fd_domains: :environment do
    MigrateBeforeForceDeleteStatusesJob.perform_later
  end

  task admin_status_history: :environment do
    MigrateStatusesToDomainHistoryJob.perform_later
  end
end
