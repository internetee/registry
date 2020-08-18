class RegenerateSubzoneWhoisesJob < Que::Job
  def run
    subzones = DNS::Zone.all

    subzones.each do |zone|
      next unless zone.subzone?

      UpdateWhoisRecordJob.enqueue zone.origin, 'zone'
    end
  end
end
