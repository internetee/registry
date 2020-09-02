namespace :contacts do
  desc 'Archives inactive contacts'

  task archive: :environment do
    inactive_contacts = InactiveContacts.new
    archived_contacts = inactive_contacts.archive

    archived_contacts.each do |contact|
      puts "Contact ##{contact.id} (code: #{contact.code}) is archived"
    end

    puts "Archived total: #{archived_contacts.count}"
  end
end
