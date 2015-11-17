class DropLogLegalDocuments < ActiveRecord::Migration
  def up
    drop_table :log_legal_documents
    remove_column :legal_documents, :updated_at
    remove_column :legal_documents, :updator_str
  end

  def down
    # removed concern Version, which removed LegalDocumentVersion
    fail ActiveRecord::IrreversibleMigration
  end
end
