class CheckForceDeleteJob < ApplicationJob
  def perform(contact_ids)
    contacts = Contact.find(contact_ids)

    contacts.each do |contact|
      next unless contact.need_to_start_force_delete?

      Domains::ForceDeleteEmail::Base.run(email: contact.email)
    end
  end
end
