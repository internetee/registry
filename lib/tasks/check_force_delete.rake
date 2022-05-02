desc 'Check Force Delete'
task :check_force_delete, :environment do
  invalid_contacts = Contact.joins(:validation_events).select do |contact|
    events = contact.validation_events
    events.mx.count >= 3 || events.regex.present?
  end.uniq(&:id)

  invalid_contacts.each do |contact|
    ValidationEventCheckForceDeleteJob.perform_later(contact.id)
  end
end
