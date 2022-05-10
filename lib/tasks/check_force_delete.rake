desc 'Check Force Delete'
task check_force_delete: :environment do

  validations = ValidationEvent.select(:validation_eventable_id).failed.where(validation_eventable_type: 'Contact').group(:validation_eventable_id)
  invalid_contact_ids = (validations.mx.having("count(event_data ->> 'success') > 2") + validations.regex).pluck(:validation_eventable_id)

  CheckForceDeleteJob.perform_later(invalid_contact_ids)
end
