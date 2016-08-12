class AddHashToLegalDoc < ActiveRecord::Migration
  def change
    add_column :legal_documents, :checksum, :string
    add_index  :legal_documents, :checksum
  end
end
