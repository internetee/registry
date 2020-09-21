namespace :contacts do
  desc 'Archives inactive contacts'

  task :archive, %i[track_id initial_run] => [:environment] do |_t, args|
    unlinked_contacts = contacts_start_point(args[:track_id])
    initial_run = args[:initial_run] == true || args[:initial_run] == 'true'
    counter = 0
    log_info("Found #{unlinked_contacts.count} unlinked contacts. Starting to archive.")

    unlinked_contacts.each do |contact|
      next unless contact.archivable?

      log_info("Archiving contact: id(#{contact.id}), code(#{contact.code})")
      contact.archive(verified: true, notify: !initial_run, extra_log: initial_run)
      counter += 1
    end

    log_info("Archived total: #{counter}")
  end

  def contacts_start_point(track_id = nil)
    puts "Starting to find archivable contacts WHERE CONTACT_ID > #{track_id}" if track_id
    return Contact.unlinked unless track_id

    Contact.unlinked.where("id > #{track_id}")
  end

  def log_info(msg)
    @log ||= Logger.new(STDOUT)
    @log.info(msg)
  end
end
