module Actions
  class ContactDelete
    attr_reader :contact
    attr_reader :new_attributes
    attr_reader :legal_document
    attr_reader :ident
    attr_reader :user

    def initialize(contact, legal_document = nil)
      @legal_document = legal_document
      @contact = contact
    end

    def call
      maybe_attach_legal_doc

      if contact.linked?
        contact.errors.add(:domains, :exist)
        return
      end

      commit
    end

    def maybe_attach_legal_doc
      return unless legal_document

      document = contact.legal_documents.create(
        document_type: legal_document[:type],
        body: legal_document[:body]
      )

      contact.legal_document_id = document.id
      contact.save
    end

    def commit
      contact.destroy
    end
  end
end
