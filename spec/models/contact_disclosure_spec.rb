require 'rails_helper'

describe ContactDisclosure do
  it { should belong_to(:contact) }

  context 'about class' do
    it 'should have versioning enabled?' do
      ContactDisclosure.paper_trail_enabled_for_model?.should == true
    end

    it 'should have custom log prexied table name for versions table' do
      ContactDisclosureVersion.table_name.should == 'log_contact_disclosures'
    end
  end

  context 'with invalid attribute' do
    before :all do
      @contact_disclosure = ContactDisclosure.new
    end

    it 'should not be valid' do
      @contact_disclosure.valid?
      @contact_disclosure.errors.full_messages.should match_array([
      ])
    end

    it 'should not have any versions' do
      @contact_disclosure.versions.should == []
    end
  end

  context 'with valid attributes' do
    before :all do
      @contact_disclosure = Fabricate(:contact_disclosure)
    end

    it 'should be valid' do
      @contact_disclosure.valid?
      @contact_disclosure.errors.full_messages.should match_array([])
    end

    it 'should be valid twice' do
      @contact_disclosure = Fabricate(:contact_disclosure)
      @contact_disclosure.valid?
      @contact_disclosure.errors.full_messages.should match_array([])
    end

    it 'should have one version' do
      with_versioning do
        @contact_disclosure.versions.should == []
        @contact_disclosure.name = false
        @contact_disclosure.save
        @contact_disclosure.errors.full_messages.should match_array([])
        @contact_disclosure.versions.size.should == 1
      end
    end
  end

end

describe '.extract_attributes' do
  it 'should return empty hash for empty arguments' do
    result = ContactDisclosure.extract_attributes(Nokogiri::XML::Document.new)
    expect(result).to eq({})
  end

  it 'should return empty hash if no disclosure' do
    parsed_frame =  Nokogiri::XML(create_contact_xml).remove_namespaces!
    result = ContactDisclosure.extract_attributes(parsed_frame)
    expect(result).to eq({})
  end

  # TODO: remodel create contact xml to support disclosure
  it 'should return disclosure has if disclosure' do
    epp_xml = EppXml::Contact.new
    xml = epp_xml.create(
      {
        disclose: { value: {
          voice: { value: '' },
          addr: { value: '' },
          name: { value: '' },
          org_name: { value: '' },
          email: { value: '' },
          fax: { value: '' }
        }, attrs: { flag: '0' }
    } })
    parsed_frame = Nokogiri::XML(xml).remove_namespaces!
    result = ContactDisclosure.extract_attributes(parsed_frame)
    expect(result).to eq({ phone: '0', email: '0', fax: '0', address: '0', name: '0', org_name: '0' })
  end
end
