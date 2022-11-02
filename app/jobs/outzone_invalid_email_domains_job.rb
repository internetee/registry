class OutzoneInvalidEmailDomainsJob < ApplicationJob
  queue_as :default

  def perform
    domains = Domain.where("force_delete_data->'template_name' = ?", 'invalid_email')
                    .where(outzone_at: nil)
                    .where('Date(force_delete_start) <= ?', Time.zone.now)

    domains.each do |domain|
      outzone(domain)
    end
  end

  private

  def outzone(domain)
    domain.outzone_at = domain.force_delete_start + Domain.expire_warning_period
    domain.delete_date = domain.outzone_at + Domain.redemption_grace_period
    domain.save
  end
end
