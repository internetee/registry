require 'rails_helper'

describe ContactDisclosure do
  it { should belong_to(:contact) }
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
