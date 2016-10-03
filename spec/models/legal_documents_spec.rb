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

      domain  = Fabricate(:domain)
      domain2 = Fabricate(:domain)
      domains = []
      domains << original  = domain.legal_documents.create!(body: Base64.encode64('S' * 4.kilobytes))
      domains << copy      = domain.legal_documents.create!(body: Base64.encode64('S' * 4.kilobytes))
      domains << skipping_as_different_domain = domain2.legal_documents.create!(body: Base64.encode64('S' * 4.kilobytes))
      domains << skipping_as_different    = domain.legal_documents.create!(body: Base64.encode64('D' * 4.kilobytes))
      domains << skipping_as_no_checksum  = domain.legal_documents.create!(checksum: nil, body: Base64.encode64('S' * 4.kilobytes))
      domains << skipping_as_no_checksum2 = domain.legal_documents.create!(checksum: "",  body: Base64.encode64('S' * 4.kilobytes))

      skipping_as_no_checksum.update_columns(checksum: nil)
      skipping_as_no_checksum2.update_columns(checksum: "")
      skipping_as_no_checksum.reload
      skipping_as_no_checksum2.reload
      skipping_as_no_checksum.path.should_not == skipping_as_no_checksum2.path

      skipping_as_no_checksum.checksum.should  == nil
      skipping_as_no_checksum2.checksum.should == ""
      original.checksum.should == copy.checksum
      original.checksum.should_not == skipping_as_different.checksum

      LegalDocument.remove_duplicates
      domains.each(&:reload)

      skipping_as_no_checksum.path.should_not be(skipping_as_no_checksum2.path)
      original.path.should_not == skipping_as_different.path
      original.path.should_not == skipping_as_different_domain.path
      original.path.should == copy.path

    end
  end

end