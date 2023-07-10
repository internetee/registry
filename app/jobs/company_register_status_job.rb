class CompanyRegisterStatusJob < ApplicationJob
  queue_as :default

  def perform(contact, days_interval = 14.days)
    return unless contact.org?

    company_status = contact.return_company_status
    return if company_status == Contact::REGISTERED || company_status == Contact::LIQUIDATED


    # TODO:
    # Need search only registrants!!!
    contacts = Contact.where(ident_type: 'org')
                .where('checked_company_at IS NULL OR checked_company_at <= ?', days_interval.days.ago)

    contact.find_in_batches(batch_size: 100) do |contacts|
      contacts.each do |contact|
        # TODO:
        # put some time interval here, otherwise it will be business registry spam
        # check contact company for status
        # if status is not registered or liquidated
        # then force delete contact

        # update checked_company_at field
      end
    end

  end
end
