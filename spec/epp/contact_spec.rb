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
      expect(Contact.first.created_by_id).to be 1
      expect(Contact.first.updated_by_id).to be nil

      expect(Contact.count).to eq(1)
      expect(Contact.first.org_name).to eq('Example Inc.')
    end

    it 'does not create duplicate contact' do
      Fabricate(:contact, code: 'sh8013')

      response = epp_request('contacts/create.xml')
      expect(response[:result_code]).to eq('2302')
      expect(response[:msg]).to eq('Contact id already exists')
      
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
      Fabricate(:contact, name: "Johnny Awesome", created_by_id: '1')
      Fabricate(:address)

      response = epp_request('contacts/info.xml')
      contact = response[:parsed].css('resData chkData')

      expect(response[:result_code]).to eq('1000')
      expect(response[:msg]).to eq('Command completed successfully')
      expect(contact.css('name').first.text).to eq('Johnny Awesome')

    end

    it 'it doesn\'t display unassociated object' do
      Fabricate(:contact, name:"Johnny Awesome", created_by_id: '240')
      Fabricate(:epp_user, id: 240)

      response = epp_request('contacts/info.xml')
      expect(response[:result_code]).to eq('2201')
      expect(response[:msg]).to eq('Authorization error')
    end

    it 'updates contact succesfully' do
      Fabricate(:contact, created_by_id: 1, email: 'not_updated@test.test', code: 'sh8013')
      response = epp_request('contacts/update.xml')
      expect(response[:msg]).to eq('Command completed successfully')
      expect(Contact.first.name).to eq('John Doe')
      expect(Contact.first.email).to eq('jdoe@example.com')
    end

    it 'returns phone and email error' do 
      Fabricate(:contact, created_by_id: 1, email: 'not_updated@test.test', code: 'sh8013')
      response = epp_request('contacts/update_with_errors.xml')

      expect(response[:results][0][:result_code]).to eq('2005')
      expect(response[:results][0][:msg]).to eq('Phone nr is invalid')

      expect(response[:results][1][:result_code]).to eq('2005')
      expect(response[:results][1][:msg]).to eq('Email is invalid')
    end
  end
end
