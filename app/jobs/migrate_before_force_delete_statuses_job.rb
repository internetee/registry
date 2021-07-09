class MigrateBeforeForceDeleteStatusesJob < ApplicationJob
  def perform
    domains = Domain.where.not(statuses_before_force_delete: nil)
    domains.each do |domain|
      domain.force_delete_domain_statuses_history = domain.statuses_before_force_delete
      domain.save
    end
  end
end
