require 'rails_helper'

describe 'EPP Contact', epp: true do
  before do
    Contact.skip_callback(:create, :before, :generate_code)
    Contact.skip_callback(:create, :before, :generate_auth_info)
  end

  after do
    Contact.set_callback(:create, :before, :generate_code)
    Contact.set_callback(:create, :before, :generate_auth_info)
  end

  let(:server_zone) { Epp::Server.new({ server: 'localhost', tag: 'zone', password: 'ghyt9e4fu', port: 701 }) }
  let(:server_elkdata) { Epp::Server.new({ server: 'localhost', tag: 'elkdata', password: 'ghyt9e4fu', port: 701 }) }
  let(:elkdata) { Fabricate(:registrar, { name: 'Elkdata', reg_no: '123' }) }
  let(:zone) { Registrar.where(reg_no: '10577829').first || Fabricate(:registrar) }

  context 'with valid user' do
    before(:each) do
      Fabricate(:epp_user)
      Fabricate(:epp_user, username: 'zone', registrar: zone)
      Fabricate(:epp_user, username: 'elkdata', registrar: elkdata)
      create_settings
    end

    context 'create command' do

      it 'fails if request xml is missing' do
        xml = EppXml::Contact.create
        response = epp_request(xml, :xml)
        expect(response[:results][0][:result_code]).to eq('2001')

        expect(response[:results][0][:msg]).to eq('Command syntax error')
        expect(response[:results].count).to eq 1
      end

      it 'fails if request xml is missing' do
        xml = EppXml::Contact.create(
          postalInfo: { addr: { value: nil } }
        )
        response = epp_request(xml, :xml)
        expect(response[:results][0][:result_code]).to eq('2003')
        expect(response[:results][1][:result_code]).to eq('2003')
        expect(response[:results][2][:result_code]).to eq('2003')
        expect(response[:results][3][:result_code]).to eq('2003')
        expect(response[:results][4][:result_code]).to eq('2003')
        expect(response[:results][5][:result_code]).to eq('2003')

        expect(response[:results][0][:msg]).to eq('Required parameter missing: name')
        expect(response[:results][1][:msg]).to eq('Required parameter missing: city')
        expect(response[:results][2][:msg]).to eq('Required parameter missing: cc')
        expect(response[:results][3][:msg]).to eq('Required parameter missing: ident')
        expect(response[:results][4][:msg]).to eq('Required parameter missing: voice')
        expect(response[:results][5][:msg]).to eq('Required parameter missing: email')
        expect(response[:results].count).to eq 6
      end

      it 'successfully creates a contact' do
        response = epp_request(create_contact_xml, :xml)

        expect(response[:result_code]).to eq('1000')
        expect(response[:msg]).to eq('Command completed successfully')

        expect(Contact.first.registrar).to eq(zone)
        expect(zone.epp_users).to include(Contact.first.created_by)
        expect(Contact.first.updated_by_id).to eq nil

        expect(Contact.count).to eq(1)

        expect(Contact.first.ident).to eq '37605030299'

        expect(Contact.first.address.street).to eq('123 Example')
      end

      it 'successfully adds registrar' do
        response = epp_request(create_contact_xml, :xml)

        expect(response[:result_code]).to eq('1000')
        expect(response[:msg]).to eq('Command completed successfully')

        expect(Contact.count).to eq(1)

        expect(Contact.first.registrar).to eq(zone)
      end

      it 'returns result data upon success' do
        response = epp_request(create_contact_xml, :xml)

        expect(response[:result_code]).to eq('1000')
        expect(response[:msg]).to eq('Command completed successfully')

        id =  response[:parsed].css('resData creData id').first
        cr_date =  response[:parsed].css('resData creData crDate').first

        expect(id.text.length).to eq(8)
        # 5 seconds for what-ever weird lag reasons might happen
        expect(cr_date.text.to_time).to be_within(5).of(Time.now)
      end
    end

    context 'update command' do
      it 'fails if request is invalid' do
        xml = EppXml::Contact.update
        response = epp_request(xml, :xml) #epp_request('contacts/update_missing_attr.xml')

        expect(response[:results][0][:result_code]).to eq('2003')
        expect(response[:results][0][:msg]).to eq('Required parameter missing: add, rem or chg')
        expect(response[:results][1][:result_code]).to eq('2003')
        expect(response[:results][1][:msg]).to eq('Required parameter missing: id')
        expect(response[:results][2][:result_code]).to eq('2003')
        expect(response[:results][2][:msg]).to eq('Required parameter missing: pw')
        expect(response[:results].count).to eq 3
      end

      it 'fails with wrong authentication info' do
        Fabricate(:contact, code: 'sh8013', auth_info: 'password_wrong')

        response = epp_request(update_contact_xml({id: { value: 'sh8013'}}), :xml, :elkdata ) #('contacts/update.xml')

        expect(response[:msg]).to eq('Authorization error')
        expect(response[:result_code]).to eq('2201')
      end

      it 'is succesful' do
        Fabricate(
          :contact,
          created_by_id: 1,
          registrar: zone,
          email: 'not_updated@test.test',
          code: 'sh8013',
          auth_info: 'password'
        )
        response = epp_request(update_contact_xml({id: { value: 'sh8013' }}), :xml)

        expect(response[:msg]).to eq('Command completed successfully')
        expect(Contact.first.name).to eq('John Doe Edited')
        expect(Contact.first.email).to eq('edited@example.example')
      end

      it 'returns phone and email error' do
        Fabricate(
          :contact,
          registrar: zone,
          created_by_id: 1,
          email: 'not_updated@test.test',
          code: 'sh8013',
          auth_info: 'password'
        )

        xml = {
          id: { value: 'sh8013' },
          chg: {
            voice: { value: '123213' },
            email: { value: 'aaa' }
          }
        }

        response = epp_request(update_contact_xml(xml), :xml)

        expect(response[:results][0][:result_code]).to eq('2005')
        expect(response[:results][0][:msg]).to eq('Phone nr is invalid')

        expect(response[:results][1][:result_code]).to eq('2005')
        expect(response[:results][1][:msg]).to eq('Email is invalid')
      end

      # it 'updates disclosure items', pending: true do
      #   pending 'Disclosure needs to be remodeled a bit'
      #   Fabricate(:contact, code: 'sh8013', auth_info: '2fooBAR', registrar: zone, created_by_id: EppUser.first.id,
      #             disclosure: Fabricate(:contact_disclosure, phone: true, email: true))
      #   epp_request('contacts/update.xml')
      #
      #   expect(Contact.last.disclosure.phone).to eq(false)
      #   expect(Contact.last.disclosure.email).to eq(false)
      #   expect(Contact.count).to eq(1)
      # end
    end

    context 'delete command' do
      it 'fails if request is invalid' do
        xml = EppXml::Contact.delete({ uid: { value: '23123' } })
        response = epp_request(xml, :xml)

        expect(response[:results][0][:result_code]).to eq('2003')
        expect(response[:results][0][:msg]).to eq('Required parameter missing: id')
        expect(response[:results].count).to eq 1
      end

      it 'deletes contact' do
        Fabricate(:contact, code: 'dwa1234', created_by_id: EppUser.first.id, registrar: zone)
        response = epp_request(delete_contact_xml({ id: { value: 'dwa1234' } }), :xml)
        expect(response[:result_code]).to eq('1000')
        expect(response[:msg]).to eq('Command completed successfully')
        expect(response[:clTRID]).to eq('ABC-12345')

        expect(Contact.count).to eq(0)
      end

      it 'returns error if obj doesnt exist' do
        response = epp_request(delete_contact_xml, :xml)
        expect(response[:result_code]).to eq('2303')
        expect(response[:msg]).to eq('Object does not exist')
      end

      it 'fails if contact has associated domain' do
        Fabricate(
          :domain,
          registrar: zone,
          owner_contact: Fabricate(
            :contact,
            code: 'dwa1234',
            created_by_id: zone.id,
            registrar: zone)
        )
        expect(Domain.first.owner_contact.address.present?).to be true
        response = epp_request(delete_contact_xml({ id: { value: 'dwa1234' } }), :xml)

        expect(response[:result_code]).to eq('2305')
        expect(response[:msg]).to eq('Object association prohibits operation')

        expect(Domain.first.owner_contact.present?).to be true

      end
    end

    context 'check command' do
      it 'fails if request is invalid' do
        xml = EppXml::Contact.check( { uid: { value: '123asde' } } )
        response = epp_request(xml, :xml)

        expect(response[:results][0][:result_code]).to eq('2003')
        expect(response[:results][0][:msg]).to eq('Required parameter missing: id')
        expect(response[:results].count).to eq 1
      end

      it 'returns info about contact availability' do
        Fabricate(:contact, code: 'check-1234')

        response = epp_request(check_multiple_contacts_xml, :xml)

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
      it 'fails if request invalid' do
        response = epp_request(EppXml::Contact.info({ uid: { value: '123123' }}), :xml )

        expect(response[:results][0][:result_code]).to eq('2003')
        expect(response[:results][0][:msg]).to eq('Required parameter missing: id')
        expect(response[:results].count).to eq 1
      end

      it 'returns error when object does not exist' do
        response = epp_request(info_contact_xml({ id: { value: 'info-4444' } }), :xml)
        expect(response[:result_code]).to eq('2303')
        expect(response[:msg]).to eq('Object does not exist')
        expect(response[:results][0][:value]).to eq('info-4444')
      end

      it 'returns info about contact' do
        @contact = Fabricate(:contact, registrar: zone, code: 'info-4444', name: 'Johnny Awesome',
                  address: Fabricate(:address))

        xml = EppXml::Contact.info(id: { value: @contact.code })
        response = epp_request(xml, :xml, :zone)
        contact = response[:parsed].css('resData chkData')

        expect(response[:result_code]).to eq('1000')
        expect(response[:msg]).to eq('Command completed successfully')
        expect(contact.css('name').first.text).to eq('Johnny Awesome')

      end

      it 'doesn\'t disclose private elements', pending: true do
        pending 'Disclosure needs to have some of the details worked out'
        Fabricate(:contact, code: 'info-4444', auth_info: '2fooBAR',
                  disclosure: Fabricate(:contact_disclosure, email: false, phone: false))
        response = epp_request(info_contact_xml( id: { value: 'info-4444' } ), :xml)
        contact = response[:parsed].css('resData chkData')

        expect(response[:result_code]).to eq('1000')

        expect(contact.css('phone').present?).to eq(false)
        expect(contact.css('email').present?).to eq(false)
        expect(contact.css('name').present?).to be(true)
      end

      it 'doesn\'t display unassociated object without password' do
        @contact = Fabricate(:contact, code: 'info-4444', registrar: zone)

        xml = EppXml::Contact.info(id: { value: @contact.code })
        response = epp_request(xml, :xml, :elkdata)
        expect(response[:result_code]).to eq('2003')
        expect(response[:msg]).to eq('Required parameter missing: pw')
      end

      it 'doesn\'t display unassociated object with wrong password' do
        @contact = Fabricate(:contact, code: 'info-4444', registrar: zone)

        xml = EppXml::Contact.info(id: { value: @contact.code }, authInfo: { pw: { value: 'qwe321' } })
        response = epp_request(xml, :xml, :elkdata)
        expect(response[:result_code]).to eq('2201')
        expect(response[:msg]).to eq('Authorization error')
      end

      it 'doest display unassociated object with correct password' do
        @contact = Fabricate(:contact, code: 'info-4444', registrar: zone, name: 'Johnny Awesome')

        xml = EppXml::Contact.info(id: { value: @contact.code }, authInfo: { pw: { value: @contact.auth_info } })
        response = epp_request(xml, :xml, :elkdata)
        contact = response[:parsed].css('resData chkData')

        expect(response[:result_code]).to eq('1000')
        expect(response[:msg]).to eq('Command completed successfully')
        expect(contact.css('name').first.text).to eq('Johnny Awesome')
      end

    end

    context 'renew command' do
      it 'returns 2101-unimplemented command' do
        response = epp_request('contacts/renew.xml')

        expect(response[:result_code]).to eq('2101')
        expect(response[:msg]).to eq('Unimplemented command')
      end
    end
  end
end
