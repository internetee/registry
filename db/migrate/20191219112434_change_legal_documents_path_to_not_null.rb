class ChangeLegalDocumentsPathToNotNull < ActiveRecord::Migration[5.0]
  def change
    change_column_null :legal_documents, :path, false
  end
end
