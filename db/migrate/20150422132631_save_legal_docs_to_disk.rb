class SaveLegalDocsToDisk < ActiveRecord::Migration[6.0]
  def change
    add_column :legal_documents, :path, :string
  end
end
