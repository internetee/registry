class CreateLegalDocuments < ActiveRecord::Migration
  def change
    create_table :legal_documents do |t|
      t.string :document_type
      t.text :body
      t.references :documentable, polymorphic: true

      t.timestamps
    end
  end
end
