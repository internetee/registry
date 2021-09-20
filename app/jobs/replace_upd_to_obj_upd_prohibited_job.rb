class ReplaceUpdToObjUpdProhibitedJob < ApplicationJob
  def perform(mode, rollback = false)
    logger.info 'Ran ReplaceUpdToObjUpdProhibitedJob!'

    start_adding_new_status_for_locked_domains(mode, rollback)
  end

  private

  def start_adding_new_status_for_locked_domains(mode, rollback)
    count = 0
    Domain.all.find_in_batches do |domain_batches|
      count += domain_batches.count
      logger.info "Proccesing #{count} domains of #{Domain.count}"

      domain_batches.each do |domain|
        if domain.locked_by_registrant?
          if rollback
            domain = rollback_actions(mode, domain)
          else
            domain = add_actions(mode, domain)
          end

          domain.save!
        end
      end

      logger.info "Successfully proccesed #{count} domains of #{Domain.count}"
    end
  end

  def rollback_actions(mode, domain)
    if mode == 'add' and !domain.statuses.include? 'serverUpdateProhibited'
      domain.statuses = domain.statuses + ['serverUpdateProhibited']
    elsif mode == 'remove' and domain.statuses.include? 'serverObjUpdateProhibited'
      domain.statuses = domain.statuses - ['serverObjUpdateProhibited']
    end

    domain
  end

  def add_actions(mode, domain)
    if mode == 'add' and !domain.statuses.include? 'serverObjUpdateProhibited'
      domain.statuses = domain.statuses + ['serverObjUpdateProhibited']
    elsif mode == 'remove' and domain.statuses.include? 'serverUpdateProhibited'
      domain.statuses = domain.statuses - ['serverUpdateProhibited']
    end

    domain
  end

  def logger
    @logger ||= Logger.new(Rails.root.join('log/migrate_before_force_delete_statuses.log'))
  end
end
