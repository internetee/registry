module Actions
  class ContactVerify
    attr_reader :contact

    def initialize(contact)
      @contact = contact
    end

    def call
      if contact.verified_at.present?
        contact.errors.add(:base, :verification_exists)
        return
      end

      create_identification_request

      return false if contact.errors.any?

      commit
    end

    private

    def create_identification_request
      ident_service = Eeid::IdentificationService.new
      request = ident_service.create_identification_request(request_payload)
      ContactMailer.identification_requested(contact: contact, link: request['link']).deliver_now
    rescue Eeid::IdentError => e
      Rails.logger.error e.message
      contact.errors.add(:base, :verification_error)
    end

    def request_payload
      {
        claims_required: [{
          type: 'sub',
          value: "#{contact.ident_country_code}#{contact.ident}"
        }],
        reference: contact.code
      }
    end

    def commit
      @contact.update(ident_request_sent_at: Time.zone.now)
    end
  end
end
