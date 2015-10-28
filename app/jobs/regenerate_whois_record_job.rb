class RegenerateWhoisRecordJob < Que::Job
  def run(ids)
    ids.each do |id|
      record = WhoisRecord.find_by(id: id)
      return unless record

      record.save
    end
  end
end