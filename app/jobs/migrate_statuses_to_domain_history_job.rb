class MigrateStatusesToDomainHistoryJob < ApplicationJob
  def perform
    logger.info 'Ran MigrateStatusesToDomainHistoryJob!'

    domains = Domain.where(locked_by_registrant_at: nil)
    logger.info "Total domains are #{domains.count}"

    interate_domain_in_batches(domains)
  end

  private

  def interate_domain_in_batches(domains)
    count = 0

    domains.find_in_batches do |domain_batches|
      count += domain_batches.count
      logger.info "Proccesing #{count} domains of #{domains.count}"
      domain_batches.each do |domain|
        migrate_data_to_admin_store_field(domain)
      end
    end
  end

  def migrate_data_to_admin_store_field(domain)
    domain.admin_store_statuses_history = domain.statuses
    domain.save
  rescue StandardError => e
    logger.warn "#{domain.name} crashed!"
    logger.warn e.to_s
    raise e
  end

  def logger
    @logger ||= Logger.new(Rails.root.join('log', 'migrate_statuses_to_domain_history.log'))
  end
end
