class ReplaceUpdToObjUpdProhibitedJob < ApplicationJob
  def perform(action:, rollback: false)
    logger.info 'Ran ReplaceUpdToObjUpdProhibitedJob!'

    start_adding_new_status_for_locked_domains(action: action, rollback: rollback)
  end

  private

  def start_adding_new_status_for_locked_domains(action:, rollback:)
    count = 0
    Domain.all.find_in_batches do |domain_batches|
      count += domain_batches.count
      logger.info "Proccesing #{count} domains of #{Domain.count}"

      domain_batches.each do |domain|
        make_actions_with_statuses(domain: domain, action: action, rollback: rollback)
      end

      logger.info "Successfully proccesed #{count} domains of #{Domain.count}"
    end
  end

  private

  def make_actions_with_statuses(domain:, action:, rollback:)
    if domain.locked_by_registrant? && rollback
      rollback_actions(action: action, domain: domain)
    elsif domain.locked_by_registrant? && !rollback
      add_actions(action: action, domain: domain)
    end
  end

  def rollback_actions(action:, domain:)
    if action == :add && !domain.statuses.include?('serverUpdateProhibited')
      domain.statuses = domain.statuses + ['serverUpdateProhibited']
      domain.save!
    elsif action == :remove && domain.statuses.include?('serverObjUpdateProhibited')
      domain.statuses = domain.statuses - ['serverObjUpdateProhibited']
      domain.save!
    end
  end

  def add_actions(action:, domain:)
    if action == :add && !domain.statuses.include?('serverObjUpdateProhibited')
      domain.statuses = domain.statuses + ['serverObjUpdateProhibited']
      domain.save!
    elsif action == :remove && domain.statuses.include?('serverUpdateProhibited')
      domain.statuses = domain.statuses - ['serverUpdateProhibited']
      domain.save!
    end
  end

  def logger
    @logger ||= Logger.new(Rails.root.join('log/migrate_before_force_delete_statuses.log'))
  end
end
