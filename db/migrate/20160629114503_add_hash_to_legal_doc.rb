class AddHashToLegalDoc < ActiveRecord::Migration
  def change
    add_column :legal_documents, :checksum, :text
  end
end
