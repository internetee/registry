class AddHashToLegalDoc < ActiveRecord::Migration[6.0]
  def change
    add_column :legal_documents, :checksum, :string
    add_index  :legal_documents, :checksum
  end
end
