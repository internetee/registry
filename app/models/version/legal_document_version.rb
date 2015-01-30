class LegalDocumentVersion < PaperTrail::Version
  include VersionSession
  self.table_name    = :log_legal_documents
  self.sequence_name = :log_legal_documents_id_seq
end
