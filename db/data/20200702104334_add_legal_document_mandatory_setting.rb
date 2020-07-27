class AddLegalDocumentMandatorySetting < ActiveRecord::Migration[6.0]
  def up
    Setting.legal_document_is_mandatory = true
  end

  def down
    Setting.find_by(var: 'legal_document_is_mandatory').delete
  end
end
