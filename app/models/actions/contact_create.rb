module Actions
  class ContactCreate
    attr_reader :contact, :legal_document

    def initialize(contact, legal_document)
      @contact = contact
      @legal_document = legal_document
    end

    def call
      maybe_remove_address
      maybe_attach_legal_doc
      commit
    end

    def maybe_remove_address
      return if Contact.address_processing?

      contact.city = nil
      contact.zip = nil
      contact.street = nil
      contact.state = nil
      contact.country_code = nil
    end

    def maybe_attach_legal_doc
      return unless legal_document

      doc = LegalDocument.create(
        documentable_type: Contact,
        document_type: legal_document[:type], body: legal_document[:body]
      )

      contact.legal_documents = [doc]
      contact.legal_document_id = doc.id
    end

    def commit
      contact.generate_code

      contact.save
    end
  end
end
