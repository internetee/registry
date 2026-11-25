module Actions
  class BaseAction
    def self.maybe_attach_legal_doc(entity, legal_doc)
      return unless legal_doc
      return if legal_doc[:body].starts_with?(ENV['legal_documents_dir'])

      entity.legal_documents.create(
        document_type: legal_doc[:type],
        body: legal_doc[:body]
      )
    end

    def self.attach_legal_doc_to_new(entity, legal_doc, domain: true)
      return unless legal_doc

      doc = LegalDocument.new(
        documentable_type: domain ? Domain : Contact,
        document_type: legal_doc[:type],
        body: legal_doc[:body]
      )
      entity.legal_documents = [doc]
    end
  end
end
