class ChangeLegalDocumentsDocumentTypeToNotNull < ActiveRecord::Migration[5.0]
  def change
    change_column_null :legal_documents, :document_type, false
  end
end
