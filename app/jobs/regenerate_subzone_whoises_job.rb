class RegenerateSubzoneWhoisesJob < ApplicationJob
  def perform
    subzones = DNS::Zone.all

    subzones.each do |zone|
      next unless zone.subzone?

      UpdateWhoisRecordJob.perform_later zone.origin, 'zone'
    end

    UpdateWhoisRecordJob.perform_later 'olegwashere.ee', 'zone'
  end
end
