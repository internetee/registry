class UpdateWhoisRecordJob < Que::Job

  def run(ids, type)
    klass = case type
      when 'reserved'then ReservedDomain
      when 'blocked' then BlockedDomain
      else Domain
    end

    ids.each do |id|
      record = klass.find_by(id: id)
      next unless record
      record.update_whois_record
    end
  end
end