class ValidationEventCheckForceDeleteJob < ApplicationJob
  def perform(event_id, contact_id)
    event = ValidationEvent.find(event_id)
    contact = Contact.find(contact_id)

    if contact.need_to_start_force_delete?
      event.start_force_delete
    elsif contact.need_to_lift_force_delete?
      event.refresh_status_notes
      event.lift_force_delete
    end
  end
end
