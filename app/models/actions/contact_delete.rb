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
      Actions::BaseAction.maybe_attach_legal_doc(contact, legal_document)
    end

    def commit
      contact.destroy
    end
  end
end
