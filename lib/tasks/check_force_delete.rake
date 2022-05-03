desc 'Check Force Delete'
task :check_force_delete, %i[batch batch_size batches_delay] => :environment do |_t, args|
  args.with_defaults(batch: false, batch_size: 1_000, batches_delay: 15)

  batch = ActiveModel::Type::Boolean.new.cast(args[:batch])
  batch_size = args[:batch_size].to_i
  batches_delay = args[:batches_delay].to_i.minutes

  invalid_contacts = Contact.joins(:validation_events).select do |contact|
    events = contact.validation_events
    mx = events.mx.select(&:failed?).count >= ValidationEvent::MX_CHECK
    regex = events.regex.select(&:failed?).present?

    (contact.need_to_start_force_delete? || contact.need_to_lift_force_delete?) && (mx || regex)
  end.uniq

  if batch
    waiting_minutes = 0.minutes

    invalid_contacts.find_in_batches(batch_size: batch_size) do |contact_batches|
      CheckForceDeleteJob.set(wait: waiting_minutes).perform_later(contact_batches)
      waiting_minutes += batches_delay
    end
  else
    invalid_contacts.each do |contact|
      CheckForceDeleteJob.perform_later([contact.id])
    end
  end
end
