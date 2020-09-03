namespace :contacts do
  desc 'Archives inactive contacts'

  task archive: :environment do
    inactive_contacts = InactiveContacts.new
    archived_contacts = inactive_contacts.archive(verified: true)

    puts "Archived total: #{archived_contacts.count}"
  end
end
