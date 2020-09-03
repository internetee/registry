namespace :contacts do
  desc 'Archives inactive contacts'

  task archive: :environment do
    puts 'Starting to gather archivable contacts'
    inactive_contacts = InactiveContacts.new
    archived_contacts = inactive_contacts.archive

    puts "Archived total: #{archived_contacts.count}"
  end
end
