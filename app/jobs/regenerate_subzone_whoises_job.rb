class RegenerateSubzoneWhoisesJob < ApplicationJob
  def perform
    subzones = DNS::Zone.all

    subzones.each do |zone|
      next unless zone.subzone?

      UpdateWhoisRecordJob.perform_later zone.origin, 'zone'
    end
  end
end
