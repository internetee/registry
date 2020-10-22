class RegenerateSubzoneWhoisesJob < ApplicationJob
  queue_as :default

  def perform
    subzones = DNS::Zone.all

    subzones.each do |zone|
      next unless zone.subzone?

      UpdateWhoisRecordJob.enqueue zone.origin, 'zone'
    end
  end
end
