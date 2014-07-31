require 'rails_helper'

describe 'EPP Contact', epp: true do
  let(:server) { Epp::Server.new({server: 'localhost', tag: 'gitlab', password: 'ghyt9e4fu', port: 701}) }

  context 'with valid user' do
    before(:each) { Fabricate(:epp_user) }

    # incomplete
    it 'creates a contact' do
      response = epp_request('contacts/create.xml')
      expect(response[:result_code]).to eq('1000')
      expect(response[:msg]).to eq('Command completed successfully')
      expect(response[:clTRID]).to eq('ABC-12345')

      expect(Contact.count).to eq(1)
      expect(Contact.first.org_name).to eq('Example Inc.')
    end

    it 'updates a contact with same ident' do
      Fabricate(:contact)
      response = epp_request('contacts/create.xml')
      expect(response[:result_code]).to eq('1000')
      expect(response[:msg]).to eq('Command completed successfully')
      expect(response[:clTRID]).to eq('ABC-12345')

      expect(Contact.first.name).to eq("John Doe")
      expect(Contact.first.ident_type).to eq("op")

      expect(Contact.count).to eq(1)
    end
    #TODO tests for missing/invalid/etc ident

    it 'deletes contact' do
      Fabricate(:contact)
      response = epp_request('contacts/delete.xml')
      expect(response[:result_code]).to eq('1000')
      expect(response[:msg]).to eq('Command completed successfully')
      expect(response[:clTRID]).to eq('ABC-12345')

      expect(Contact.count).to eq(0)
    end

    it 'deletes an nil object' do
      response = epp_request('contacts/delete.xml')
      expect(response[:result_code]).to eq('2303')
      expect(response[:msg]).to eq('Object does not exist')
    end

    it 'checks contacts' do
      Fabricate(:contact)
      Fabricate(:contact, id:'sh8914')
      
      response = epp_request('contacts/check.xml')
      expect(response[:result_code]).to eq('1000')
      expect(response[:msg]).to eq('Command completed successfully')
      ids = response[:parsed].css('resData chkData id')

      expect(ids[0].attributes['avail'].text).to eq('0')
      expect(ids[1].attributes['avail'].text).to eq('1')

      expect(ids[0].text).to eq('sh8913')
      expect(ids[1].text).to eq('sh8914')

    end

    it 'returns error when object does not exist' do
      response = epp_request('contacts/info.xml')
      expect(response[:result_code]).to eq('2303')
      expect(response[:msg]).to eq('Object does not exist')
    end

    it 'returns info about contact' do
      Fabricate(:contact, :name => "Johnny Awesome")
      Fabricate(:address)

      response = epp_request('contacts/info.xml')
      contact = response[:parsed].css('resData chkData')

      expect(response[:result_code]).to eq('1000')
      expect(response[:msg]).to eq('Command completed successfully')
      expect(contact.css('name').first.text).to eq('Johnny Awesome')

    end
  end
end
