desc 'Check Force Delete'
task check_force_delete: :environment do
  validations = ValidationEvent.failed.where(validation_eventable_type: 'Contact').uniq(&:validation_eventable_id)
  
  unless validations.blank?
    invalid_contact_ids = validations.select do |validation|
      contact = validation.validation_eventable
      next unless contact

      contact.need_to_start_force_delete?
    end.pluck(:validation_eventable_id)

    CheckForceDeleteJob.perform_later(invalid_contact_ids) if invalid_contact_ids.present?
  end
end
