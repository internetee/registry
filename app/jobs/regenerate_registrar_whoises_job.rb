class RegenerateRegistrarWhoisesJob < Que::Job
  def run(registrar_id)
    # no return as we want restart job if fails
    registrar = Registrar.find(registrar_id)

    registrar.whois_records.select(:name).find_in_batches(batch_size: 20) do |group|
      UpdateWhoisRecordJob.enqueue group.map(&:name), 'domain'
    end
  end
end