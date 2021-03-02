class UpdateWhoisRecordJob < ApplicationJob
  queue_as :default

  def perform(names, type)
    Whois::Update.run(names: [names].flatten, type: type)
  end
end
