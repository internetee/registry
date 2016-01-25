class UpdateWhoisRecordJob < Que::Job
  def run(ids, type)
    ids.each do |id|
      record = WhoisRecord.find_by(id: id)
      return unless record

      record.save
    end
  end
end