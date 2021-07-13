class MigrateBeforeForceDeleteStatusesJob < ApplicationJob
  def perform
    logger.info 'Ran MigrateBeforeForceDeleteStatusesJob!'

    domains = Domain.where.not(statuses_before_force_delete: nil)
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
        migrate_data_to_statuses_history(domain)
      end
    end
  end

  def migrate_data_to_statuses_history(domain)
    domain.force_delete_domain_statuses_history = domain.statuses_before_force_delete
    domain.save
  rescue StandardError => e
    logger.warn "#{domain.name} crashed!"
    logger.warn e.to_s
    raise e
  end

  def logger
    @logger ||= Logger.new(Rails.root.join('log', 'migrate_before_force_delete_statuses.log'))
  end
end
