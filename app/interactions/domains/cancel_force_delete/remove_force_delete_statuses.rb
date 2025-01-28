module Domains
  module CancelForceDelete
    class RemoveForceDeleteStatuses < Base
      def execute
        domain_statuses = [DomainStatus::FORCE_DELETE,
                           DomainStatus::SERVER_RENEW_PROHIBITED,
                           DomainStatus::SERVER_TRANSFER_PROHIBITED,
                           DomainStatus::CLIENT_HOLD]
        domain.force_delete_domain_statuses_history += [ DomainStatus::SERVER_TRANSFER_PROHIBITED,
                                                         DomainStatus::SERVER_OBJ_UPDATE_PROHIBITED,
                                                         DomainStatus::SERVER_DELETE_PROHIBITED
                                                       ] if domain.locked_by_registrant?

        domain.admin_store_statuses_history -= domain_statuses unless domain.admin_store_statuses_history.nil?
        rejected_statuses = domain.statuses.reject { |a| domain_statuses.include? a }
        domain.statuses = rejected_statuses
        domain.skip_whois_record_update = true
        domain.save(validate: false)
      end
    end
  end
end
