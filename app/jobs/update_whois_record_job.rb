class UpdateWhoisRecordJob < ApplicationJob
  def perform(names, type)
    Whois::Update.run(names: [names].flatten, type: type)
  end
end
