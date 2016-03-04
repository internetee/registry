class RegenerateWhoisRecordJob < Que::Job
  def run(ids, attr = :id)
    ids.each do |id|
      record = WhoisRecord.find_by(attr => id)
      return unless record

      record.save
    end
  end
end