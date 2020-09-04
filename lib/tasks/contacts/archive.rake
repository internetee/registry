namespace :contacts do
  desc 'Archives inactive contacts'

  task :archive, [:track_id] => [:environment] do |_t, args|
    unlinked_contacts = contacts_start_point(args[:track_id])

    counter = 0
    puts "Found #{unlinked_contacts.count} unlinked contacts. Starting to archive."

    unlinked_contacts.each do |contact|
      next unless contact.archivable?

      puts "Archiving contact: id(#{contact.id}), code(#{contact.code})"
      contact.archive(verified: true)
      counter += 1
    end

    puts "Archived total: #{counter}"
  end

  def contacts_start_point(track_id = nil)
    puts "Starting to find archivable contacts WHERE CONTACT_ID > #{track_id}" if track_id
    return Contact.unlinked unless track_id

    Contact.unlinked.where("id > #{track_id}")
  end
end
