class ForceDeleteLiftJob < ApplicationJob
  queue_as :default

  def perform
    domains = Domain.where("force_delete_data->'template_name' = ?", 'invalid_email')
                    .where("force_delete_data->'force_delete_type' = ?", 'soft')

    domains.each do |domain|
      Domains::ForceDeleteLift::Base.run(domain: domain)
    end
  end
end
