class UpdateWhoisRecordJob < Que::Job
  def run(names, type)
    Whois::Update.run(names: [names].flatten, type: type)
  end
end
