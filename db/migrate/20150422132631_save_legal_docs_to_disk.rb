class SaveLegalDocsToDisk < ActiveRecord::Migration
  def change
    add_column :legal_documents, :path, :string
  end
end
