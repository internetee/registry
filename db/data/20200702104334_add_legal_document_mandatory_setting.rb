class AddLegalDocumentMandatorySetting < ActiveRecord::Migration[6.0]
  def up
    Setting.create(code: 'legal_document_is_mandatory',
                   value: 'true', format: 'boolean',
                   group: 'domain_validation')
  end

  def down
    Setting.find_by(code: 'legal_document_is_mandatory').destroy
  end
end
