require 'rails_helper'

describe LegalDocument do
  context 'tasks' do
    it 'make files uniq' do
      Fabricate(:zonefile_setting, origin: 'ee')
      Fabricate(:zonefile_setting, origin: 'pri.ee')
      Fabricate(:zonefile_setting, origin: 'med.ee')
      Fabricate(:zonefile_setting, origin: 'fie.ee')
      Fabricate(:zonefile_setting, origin: 'com.ee')
      LegalDocument.explicitly_write_file = true
      PaperTrail.enabled = true

      domain  = Fabricate(:domain)
      domain2 = Fabricate(:domain)
      legals = []
      legals << original  = domain.legal_documents.create!(body: Base64.encode64('S' * 4.kilobytes))
      legals << copy      = domain.legal_documents.create!(body: Base64.encode64('S' * 4.kilobytes))
      legals << skipping_as_different_domain = domain2.legal_documents.create!(body: Base64.encode64('S' * 4.kilobytes))
      legals << skipping_as_different    = domain.legal_documents.create!(body: Base64.encode64('D' * 4.kilobytes))
      legals << skipping_as_no_checksum  = domain.legal_documents.create!(checksum: nil, body: Base64.encode64('S' * 4.kilobytes))
      legals << skipping_as_no_checksum2 = domain.legal_documents.create!(checksum: "",  body: Base64.encode64('S' * 4.kilobytes))
      legals << registrant_copy = domain.registrant.legal_documents.create!(body: Base64.encode64('S' * 4.kilobytes))
      legals << registrant_skipping_as_different = domain.registrant.legal_documents.create!(body: Base64.encode64('Q' * 4.kilobytes))
      legals << tech_copy = domain.tech_contacts.first.legal_documents.create!(body: Base64.encode64('S' * 4.kilobytes))
      legals << tech_skipping_as_different = domain.tech_contacts.first.legal_documents.create!(body: Base64.encode64('W' * 4.kilobytes))
      legals << admin_copy = domain.admin_contacts.first.legal_documents.create!(body: Base64.encode64('S' * 4.kilobytes))
      legals << admin_skipping_as_different = domain.admin_contacts.first.legal_documents.create!(body: Base64.encode64('E' * 4.kilobytes))
      legals << new_second_tech_contact     = domain2.tech_contacts.first.legal_documents.create!(body: Base64.encode64('S' * 4.kilobytes))
      domain.tech_contacts << domain2.tech_contacts.first


      # writing nesting to history
      domain.update(updated_at: Time.now)
      domain2.update(updated_at: Time.now)
      domain.reload

      skipping_as_no_checksum.update_columns(checksum: nil)
      skipping_as_no_checksum2.update_columns(checksum: "")
      skipping_as_no_checksum.reload
      skipping_as_no_checksum2.reload
      skipping_as_no_checksum.path.should_not == skipping_as_no_checksum2.path

      skipping_as_no_checksum.checksum.should  == nil
      skipping_as_no_checksum2.checksum.should == ""
      original.checksum.should == copy.checksum
      original.checksum.should_not == skipping_as_different.checksum
      domain.tech_contacts.count.should == 2

      LegalDocument.remove_duplicates
      LegalDocument.remove_duplicates
      LegalDocument.remove_duplicates
      legals.each(&:reload)

      skipping_as_no_checksum.path.should_not be(skipping_as_no_checksum2.path)
      original.path.should_not == skipping_as_different.path
      original.path.should_not == skipping_as_different_domain.path
      original.path.should_not == registrant_skipping_as_different.path
      original.path.should_not == tech_skipping_as_different.path
      original.path.should_not == admin_skipping_as_different.path
      original.path.should == copy.path
      original.path.should == registrant_copy.path
      original.path.should == tech_copy.path
      original.path.should == admin_copy.path

      original.path.should == new_second_tech_contact.path
      skipping_as_different_domain.path.should_not == new_second_tech_contact.path
    end
  end

end