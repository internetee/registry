require 'benchmark'

# INSTRUCTIONS:
# The task works as follows, it finds a domain that has a domain lock mark and replaces the status serverUpdateProhibited with serverObjUpdateProhibited
# For run this task it need to type `rake locked_domains:replace_new_status`
# Whole results will saved into log/replace_upd_to_obj_upd_prohibited.log
# It need to make sure before launching that these statuses mean that the domain has a domain lock, otherwise this scanner will not find the required domains.
# Therefore, it is better that the value `enable_lock_domain_with_new_statuses` in the `application.yml` file is commented out or has the status false before starting. After the task has been completed, set the value `enable_lock_domain_with_new_statuses` to true, and then the domain with the following statuses `serverDeleteProhibited, serverTransferProhibited, serverObjUpdateProhibite` will be considered blocked now.

# If for some reason it need to roll back the result, then this value `enable_lock_domain_with_new_statuses` must be true, and run the command `rake locked_domains:rollback_replacement_new_status`

namespace :locked_domains do
  desc 'Replace serverUpdateProhibited to serverObjUpdateProhibited for locked domains'
  task replace_new_status: :environment do
    ReplaceUpdToObjUpdProhibitedJob.perform_later
  end

  desc 'Replace serverObjUpdateProhibited to serverUpdateProhibited for locked domains'
  task rollback_replacement_new_status: :environment do
    ReplaceUpdToObjUpdProhibitedJob.perform_later(rollback: true)
  end
end
