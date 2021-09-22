class ReplaceUpdToObjUpdProhibitedJob < ApplicationJob
  def perform(rollback: false)
    logger.info 'Ran ReplaceUpdToObjUpdProhibitedJob!'

    start_replace_status_for_locked_domains(rollback: rollback)
  end


  def start_replace_status_for_locked_domains(rollback:)
    count = 0
    Domain.all.find_in_batches do |domain_batches|
      count += domain_batches.count
      logger.info "Proccesing #{count} domains of #{Domain.count}"

      domain_batches.each do |domain|
        if domain.locked_by_registrant? 
          process_domain_status_replacment(domain: domain, rollback: rollback)
        end
      end

      logger.info "Successfully proccesed #{count} domains of #{Domain.count}"
    end
  end

  private

  def process_domain_status_replacment(domain:, rollback:)
    domain.statuses = domain.statuses - ["serverUpdateProhibited"] + ["serverObjUpdateProhibited"] unless rollback
    domain.statuses = domain.statuses - ["serverObjUpdateProhibited"] + ["serverUpdateProhibited"] if rollback
    if domain.save
      logger.info "#{domain.name} has next statuses #{domain.statuses}"
    else
      logger.warn "#{domain.name} - something goes wrong!"
    end
  end

  def logger
    @logger ||= Logger.new(Rails.root.join('log/replace_upd_to_obj_upd_prohibited.log'))
  end
end
