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
    f = File.open('spec/epp/requests/contacts/create_with_two_addresses.xml')
    parsed_frame = Nokogiri::XML(f).remove_namespaces!
    f.close
    result = ContactDisclosure.extract_attributes(parsed_frame)
    expect(result).to eq({ phone: '0', email: '0' })
  end
end
