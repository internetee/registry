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
            domain.statuses = domain.statuses + ["serverUpdateProhibited"] if mode == 'add' and !domain.statuses.include? "serverUpdateProhibited"
            domain.statuses = domain.statuses - ["serverObjUpdateProhibited"] if mode == 'remove' and domain.statuses.include? "serverObjUpdateProhibited"
          else
            domain.statuses = domain.statuses + ["serverObjUpdateProhibited"] if mode == 'add' and !domain.statuses.include? "serverObjUpdateProhibited"
            domain.statuses = domain.statuses - ["serverUpdateProhibited"] if mode == 'remove'  and domain.statuses.include? "serverUpdateProhibited"
          end
          domain.save!
        end
      end
      logger.info "Successfully proccesed #{count} domains of #{Domain.count}"
    end
  end

  def logger
    @logger ||= Logger.new(Rails.root.join('log/migrate_before_force_delete_statuses.log'))
  end
end
