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
  let(:zone) { Registrar.where(reg_no: '12345678').first || Fabricate(:registrar) }
  let(:epp_xml) { EppXml::Contact.new(cl_trid: 'ABC-12345') }

  context 'with valid user' do
    before(:each) do
      Fabricate(:epp_user)
      Fabricate(:epp_user, username: 'zone', registrar: zone)
      Fabricate(:epp_user, username: 'elkdata', registrar: elkdata)
      create_settings
      create_disclosure_settings
    end

    context 'create command' do
      it 'fails if request xml is missing' do
        xml = epp_xml.create
        response = epp_request(xml, :xml)
        expect(response[:results][0][:result_code]).to eq('2001')

        expect(response[:results][0][:msg]).to eq('Command syntax error')
        expect(response[:results].count).to eq 1
      end

      it 'fails if request xml is missing' do
        xml = epp_xml.create(
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

      it 'successfully saves ident type' do
        xml = { ident: { value: '1990-22-12', attrs: { type: 'birthday' } } }
        epp_request(create_contact_xml(xml), :xml)
        expect(Contact.last.ident_type).to eq('birthday')
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

        log = ApiLog::EppLog.all

        expect(log.length).to eq(4)
        expect(log[0].request_command).to eq('hello')
        expect(log[0].request_successful).to eq(true)

        expect(log[1].request_command).to eq('login')
        expect(log[1].request_successful).to eq(true)
        expect(log[1].api_user_name).to eq('zone')
        expect(log[1].api_user_registrar).to eq('Registrar OÜ')

        expect(log[2].request_command).to eq('create')
        expect(log[2].request_object).to eq('contact')
        expect(log[2].request_successful).to eq(true)
        expect(log[2].api_user_name).to eq('zone')
        expect(log[2].api_user_registrar).to eq('Registrar OÜ')
        expect(log[2].request).not_to be_blank
        expect(log[2].response).not_to be_blank

        expect(log[3].request_command).to eq('logout')
        expect(log[3].request_successful).to eq(true)
        expect(log[3].api_user_name).to eq('zone')
        expect(log[3].api_user_registrar).to eq('Registrar OÜ')
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

      it 'creates disclosure data' do
        xml = {
          disclose: { value: {
            voice: { value: '' },
            addr: { value: '' },
            name: { value: '' },
            org_name: { value: '' },
            email: { value: '' },
            fax: { value: '' }
          }, attrs: { flag: '1' }
          }
        }

        response = epp_request(create_contact_xml(xml), :xml)
        expect(response[:result_code]).to eq('1000')

        expect(Contact.last.disclosure.name).to eq(true)
        expect(Contact.last.disclosure.org_name).to eq(true)
        expect(Contact.last.disclosure.phone).to eq(true)
        expect(Contact.last.disclosure.fax).to eq(true)
        expect(Contact.last.disclosure.email).to eq(true)
        expect(Contact.last.disclosure.address).to eq(true)
      end

      it 'creates disclosure data merging with defaults' do
        xml = {
          disclose: { value: {
            voice: { value: '' },
            addr: { value: '' }
          }, attrs: { flag: '1' }
          }
        }

        response = epp_request(create_contact_xml(xml), :xml)
        expect(response[:result_code]).to eq('1000')

        expect(Contact.last.disclosure.name).to eq(nil)
        expect(Contact.last.disclosure.org_name).to eq(nil)
        expect(Contact.last.disclosure.phone).to eq(true)
        expect(Contact.last.disclosure.fax).to eq(nil)
        expect(Contact.last.disclosure.email).to eq(nil)
        expect(Contact.last.disclosure.address).to eq(true)
      end
    end

    context 'update command' do
      it 'fails if request is invalid' do
        xml = epp_xml.update
        response = epp_request(xml, :xml) # epp_request('contacts/update_missing_attr.xml')

        expect(response[:results][0][:result_code]).to eq('2003')
        expect(response[:results][0][:msg]).to eq('Required parameter missing: add, rem or chg')
        expect(response[:results][1][:result_code]).to eq('2003')
        expect(response[:results][1][:msg]).to eq('Required parameter missing: id')
        expect(response[:results].count).to eq 2
      end

      it 'fails with wrong authentication info' do
        Fabricate(:contact, code: 'sh8013', auth_info: 'password_wrong')

        response = epp_request(update_contact_xml({ id: { value: 'sh8013' } }), :xml, :elkdata)

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
        response = epp_request(update_contact_xml({ id: { value: 'sh8013' } }), :xml)

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

      it 'updates disclosure items' do
        Fabricate(:contact, code: 'sh8013', auth_info: '2fooBAR', registrar: zone, created_by_id: EppUser.first.id,
                  disclosure: Fabricate(:contact_disclosure, phone: true, email: true))

        xml = {
          id: { value: 'sh8013' },
          authInfo: { pw: { value: '2fooBAR' } }
        }
        @response = epp_request(update_contact_xml(xml), :xml)

        expect(@response[:results][0][:result_code]).to eq('1000')

        expect(Contact.last.disclosure.phone).to eq(false)
        expect(Contact.last.disclosure.email).to eq(false)
        expect(Contact.count).to eq(1)
      end
    end

    context 'delete command' do
      it 'fails if request is invalid' do
        xml = epp_xml.delete({ uid: { value: '23123' } })
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
        xml = epp_xml.check({ uid: { value: '123asde' } })
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
      it 'discloses items with wrong password when queried by owner' do
        @contact = Fabricate(:contact, registrar: zone, code: 'info-4444', name: 'Johnny Awesome', auth_info: 'asde',
                  address: Fabricate(:address), disclosure: Fabricate(:contact_disclosure, name: false))

        xml = epp_xml.info({ id: { value: @contact.code } })
        response = epp_request(xml, :xml, :zone)
        contact = response[:parsed].css('resData chkData')

        expect(response[:result_code]).to eq('1000')
        expect(response[:msg]).to eq('Command completed successfully')
        expect(contact.css('name').first.text).to eq('Johnny Awesome')
      end

      it 'returns auth error for non-owner with wrong password' do
        @contact = Fabricate(:contact, registrar: elkdata, code: 'info-4444', name: 'Johnny Awesome', auth_info: 'asde',
                  address: Fabricate(:address), disclosure: Fabricate(:contact_disclosure, name: false))

        xml = epp_xml.info({ id: { value: @contact.code }, authInfo: { pw: { value: 'asdesde' } } })
        response = epp_request(xml, :xml, :zone)

        expect(response[:result_code]).to eq('2200')
        expect(response[:msg]).to eq('Authentication error')
      end

      it 'doesn\'t disclose items to non-owner with right password' do
        @contact = Fabricate(:contact, registrar: elkdata, code: 'info-4444',
                  name: 'Johnny Awesome', auth_info: 'password',
                  address: Fabricate(:address), disclosure: Fabricate(:contact_disclosure, name: false))

        xml = epp_xml.info({ id: { value: @contact.code }, authInfo: { pw: { value: 'password' } } })
        response = epp_request(xml, :xml, :zone)
        contact = response[:parsed].css('resData chkData')

        expect(response[:result_code]).to eq('1000')
        expect(response[:msg]).to eq('Command completed successfully')
        expect(contact.css('chkData postalInfo name').first).to eq(nil)
      end

      it 'discloses items to owner' do
        @contact = Fabricate(:contact, registrar: zone, code: 'info-4444', name: 'Johnny Awesome',
                  auth_info: 'password',
                  address: Fabricate(:address), disclosure: Fabricate(:contact_disclosure, name: false))

        xml = epp_xml.info({ id: { value: @contact.code } })
        response = epp_request(xml, :xml, :zone)
        contact = response[:parsed].css('resData chkData')

        expect(response[:result_code]).to eq('1000')
        expect(response[:msg]).to eq('Command completed successfully')
        expect(contact.css('name').first.text).to eq('Johnny Awesome')
      end

      it 'fails if request invalid' do
        response = epp_request(epp_xml.info({ uid: { value: '123123' } }), :xml)

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

        xml = epp_xml.info(id: { value: @contact.code })
        response = epp_request(xml, :xml, :zone)
        contact = response[:parsed].css('resData chkData')

        expect(response[:result_code]).to eq('1000')
        expect(response[:msg]).to eq('Command completed successfully')
        expect(contact.css('name').first.text).to eq('Johnny Awesome')

      end

      it 'doesn\'t disclose private elements' do
        Fabricate(:contact, code: 'info-4444', auth_info: '2fooBAR', registrar: elkdata,
                  disclosure: Fabricate(:contact_disclosure, name: true, email: false, phone: false))

        xml = epp_xml.info({ id: { value: 'info-4444' }, authInfo: { pw: { value: '2fooBAR' } } })

        response = epp_request(xml, :xml, :zone)
        contact = response[:parsed].css('resData chkData')

        expect(response[:result_code]).to eq('1000')

        expect(contact.css('chkData phone')).to eq(contact.css('chkData disclose phone'))
        expect(contact.css('chkData phone').count).to eq(1)
        expect(contact.css('chkData email')).to eq(contact.css('chkData disclose email'))
        expect(contact.css('chkData email').count).to eq(1)
        expect(contact.css('postalInfo name').present?).to be(true)
      end

      it 'doesn\'t display unassociated object without password' do
        @contact = Fabricate(:contact, code: 'info-4444', registrar: zone)

        xml = epp_xml.info(id: { value: @contact.code })
        response = epp_request(xml, :xml, :elkdata)
        expect(response[:result_code]).to eq('2003')
        expect(response[:msg]).to eq('Required parameter missing: pw')
      end

      it 'doesn\'t display unassociated object with wrong password' do
        @contact = Fabricate(:contact, code: 'info-4444', registrar: zone)

        xml = epp_xml.info(id: { value: @contact.code }, authInfo: { pw: { value: 'qwe321' } })
        response = epp_request(xml, :xml, :elkdata)
        expect(response[:result_code]).to eq('2200')
        expect(response[:msg]).to eq('Authentication error')
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
