module Actions
  # The ContactVerify class is responsible for handling the verification process
  # for a contact, including creating identification requests and updating the
  # contact's verification status.
  class ContactVerify
    attr_reader :contact

    def initialize(contact)
      @contact = contact
    end

    def call
      return false unless %w[priv birthday].include? contact.ident_type

      create_identification_request

      return false if contact.errors.any?

      commit
    end

    private

    def create_identification_request
      ident_service = Eeid::IdentificationService.new(contact.ident_type)
      response = ident_service.create_identification_request(request_payload)
      ContactMailer.identification_requested(contact: contact, link: response['link']).deliver_now
    rescue Eeid::IdentError => e
      Rails.logger.error e.message
      contact.errors.add(:base, :verification_error)
    end

    def request_payload
      if contact.ident_type == 'birthday'
        birthday_payload
      else
        default_payload
      end
    end

    def birthday_payload
      {
        claims_required: [
          { type: 'birthdate', value: contact.ident },
          { type: 'name', value: contact.name }
        ],
        reference: contact.code
      }
    end

    def default_payload
      {
        claims_required: [{
          type: 'sub',
          value: "#{contact.ident_country_code}#{contact.ident}"
        }],
        reference: contact.code
      }
    end

    def commit
      @contact.update(
        ident_request_sent_at: Time.zone.now,
        verified_at: nil,
        verification_id: nil
      )
    end
  end
end
