require 'rails_helper'

describe 'EPP Contact', epp: true do
  let(:server) { Epp::Server.new({server: 'localhost', tag: 'gitlab', password: 'ghyt9e4fu', port: 701}) }

  context 'with valid user' do
    before(:each) { Fabricate(:epp_user) }

    context 'create command' do
      it "fails if request is invalid" do
        response = epp_request(contact_create_xml( { authInfo: [false], addr: { cc: false, city: false } }  ), :xml)

        expect(response[:results][0][:result_code]).to eq('2003')
        expect(response[:results][1][:result_code]).to eq('2003')
        expect(response[:results][2][:result_code]).to eq('2003')

        expect(response[:results][0][:msg]).to eq('Required parameter missing: city')
        expect(response[:results][1][:msg]).to eq('Required parameter missing: cc')
        expect(response[:results][2][:msg]).to eq('Required parameter missing: authInfo')
        expect(response[:results].count).to eq 3
      end

      it 'successfully creates a contact' do
        response = epp_request(contact_create_xml, :xml)

        expect(response[:result_code]).to eq('1000')
        expect(response[:msg]).to eq('Command completed successfully')
        expect(response[:clTRID]).to eq('ABC-12345')
        expect(Contact.first.created_by_id).to be 1
        expect(Contact.first.updated_by_id).to be nil

        expect(Contact.count).to eq(1)
        expect(Contact.first.org_name).to eq('Example Inc.')

        expect(Contact.first.address.street).to eq('123 Example Dr.')
        expect(Contact.first.address.street2).to eq('Suite 100')
        expect(Contact.first.address.street3).to eq nil

      end

      it 'returns result data upon success' do
        response = epp_request(contact_create_xml, :xml)

        expect(response[:result_code]).to eq('1000')
        expect(response[:msg]).to eq('Command completed successfully')

        id =  response[:parsed].css('resData creData id').first
        crDate =  response[:parsed].css('resData creData crDate').first

        expect(id.text).to eq('sh8013')
        #5 seconds for what-ever weird lag reasons might happen
        expect(crDate.text.to_time).to be_within(5).of(Time.now)
 
      end

      it 'does not create duplicate contact' do
        Fabricate(:contact, code: 'sh8013')

        response = epp_request(contact_create_xml, :xml)

        expect(response[:result_code]).to eq('2302')
        expect(response[:msg]).to eq('Contact id already exists')
        
        expect(Contact.count).to eq(1)
      end
    end


    context 'update command' do
      it "fails if request is invalid" do
        response = epp_request('contacts/update_missing_attr.xml')
        #response = epp_request(contact_update_xml( {id: false} ), :xml)
  
        expect(response[:results][0][:result_code]).to eq('2003')
        expect(response[:results][0][:msg]).to eq('Required parameter missing: id')
        expect(response[:results].count).to eq 1
      end
  
      it 'stamps updated_by succesfully' do
        Fabricate(:contact, code: 'sh8013')
  
        expect(Contact.first.updated_by_id).to be nil
  
        response = epp_request(contact_update_xml, :xml)

        expect(Contact.first.updated_by_id).to eq 1
      end
  
      it 'is succesful' do
        Fabricate(:contact, created_by_id: 1, email: 'not_updated@test.test', code: 'sh8013')
        #response = epp_request(contact_update_xml( { chg: { email: 'fred@bloggers.ee', postalInfo: { name: 'Fred Bloggers' } } } ), :xml)
        response = epp_request('contacts/update.xml')

        expect(response[:msg]).to eq('Command completed successfully')
        expect(Contact.first.name).to eq('John Doe')
        expect(Contact.first.email).to eq('jdoe@example.com')
      end
  
      it 'returns phone and email error' do 
        Fabricate(:contact, created_by_id: 1, email: 'not_updated@test.test', code: 'sh8013')
        #response = epp_request(contact_update_xml( { chg: { email: "qwe", phone: "123qweasd" } }), :xml)
        response = epp_request('contacts/update_with_errors.xml')
  
        expect(response[:results][0][:result_code]).to eq('2005')
        expect(response[:results][0][:msg]).to eq('Phone nr is invalid')
  
        expect(response[:results][1][:result_code]).to eq('2005')
        expect(response[:results][1][:msg]).to eq('Email is invalid')
      end
    end 

    context 'delete command' do
      it "fails if request is invalid" do
        response = epp_request('contacts/delete_missing_attr.xml')

        expect(response[:results][0][:result_code]).to eq('2003')
        expect(response[:results][0][:msg]).to eq('Required parameter missing: id')
        expect(response[:results].count).to eq 1
      end

      it 'deletes contact' do
        Fabricate(:contact, code: "dwa1234")
        response = epp_request('contacts/delete.xml')
        expect(response[:result_code]).to eq('1000')
        expect(response[:msg]).to eq('Command completed successfully')
        expect(response[:clTRID]).to eq('ABC-12345')

        expect(Contact.count).to eq(0)
      end

      it 'returns error if obj doesnt exist' do
        response = epp_request('contacts/delete.xml')
        expect(response[:result_code]).to eq('2303')
        expect(response[:msg]).to eq('Object does not exist')
      end
    end


    context 'check command' do
      it "fails if request is invalid" do
        response = epp_request(contact_check_xml( ids: [ false ] ), :xml)

        expect(response[:results][0][:result_code]).to eq('2003')
        expect(response[:results][0][:msg]).to eq('Required parameter missing: id')
        expect(response[:results].count).to eq 1
      end

      it 'returns info about contact' do
        Fabricate(:contact, code: 'check-1234')
        
        response = epp_request(contact_check_xml( ids: [{ id: 'check-1234'}, { id: 'check-4321' }]  ), :xml)

        expect(response[:result_code]).to eq('1000')
        expect(response[:msg]).to eq('Command completed successfully')
        ids = response[:parsed].css('resData chkData id')

        expect(ids[0].attributes['avail'].text).to eq('0')
        expect(ids[1].attributes['avail'].text).to eq('1')

        expect(ids[0].text).to eq('check-1234')
        expect(ids[1].text).to eq('check-4321')
      end
    end
 
    context 'info command' do
      it "fails if request invalid" do
        response = epp_request('contacts/delete_missing_attr.xml')

        expect(response[:results][0][:result_code]).to eq('2003')
        expect(response[:results][0][:msg]).to eq('Required parameter missing: id')
        expect(response[:results].count).to eq 1
      end

      it 'returns error when object does not exist' do
        response = epp_request('contacts/info.xml')
        expect(response[:result_code]).to eq('2303')
        expect(response[:msg]).to eq('Object does not exist')
        expect(response[:results][0][:value]).to eq('info-4444')
      end

      it 'returns info about contact' do
        Fabricate(:contact, name: "Johnny Awesome", created_by_id: '1', code: 'info-4444')
        Fabricate(:address)

        response = epp_request('contacts/info.xml')
        contact = response[:parsed].css('resData chkData')

        expect(response[:result_code]).to eq('1000')
        expect(response[:msg]).to eq('Command completed successfully')
        expect(contact.css('name').first.text).to eq('Johnny Awesome')

      end

      it 'doesn\'t display unassociated object' do
        Fabricate(:contact, name:"Johnny Awesome", created_by_id: '240', code: 'info-4444')
        Fabricate(:epp_user, id: 240)

        response = epp_request('contacts/info.xml')
        expect(response[:result_code]).to eq('2201')
        expect(response[:msg]).to eq('Authorization error')
      end
    end
  end
end
