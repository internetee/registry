class MigrateStatusesToDomainHistoryJob < ApplicationJob
  def perform
    domains = Domain.where(locked_by_registrant_at: nil)
    domains.each do |domain|
      domain.admin_store_statuses_history = domain.statuses
      domain.save
    end
  end
end
