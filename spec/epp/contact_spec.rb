require 'rails_helper'

describe 'EPP Contact', epp: true do
  before :all do
    Fabricate(:epp_user)
    Fabricate(:epp_user, username: 'registrar1', registrar: registrar1)
    Fabricate(:epp_user, username: 'registrar2', registrar: registrar2)

    login_as :gitlab

    Contact.skip_callback(:create, :before, :generate_code)
    Contact.skip_callback(:create, :before, :generate_auth_info)
    create_settings
    create_disclosure_settings
  end

  after :all do
    Contact.set_callback(:create, :before, :generate_code)
    Contact.set_callback(:create, :before, :generate_auth_info)
  end

  context 'with valid user' do
    context 'create command' do
      it 'fails if request xml is missing' do
        xml = epp_xml.create
        response = epp_plain_request(xml, :xml)
        response[:results][0][:msg].should == 'Command syntax error'
        response[:results][0][:result_code].should == '2001'

        response[:results].count.should == 1
      end

      it 'fails if request xml is missing' do
        xml = epp_xml.create(
          postalInfo: { addr: { value: nil } }
        )
        response = epp_plain_request(xml, :xml)
        response[:results][0][:msg].should == 'Required parameter missing: name'
        response[:results][1][:msg].should == 'Required parameter missing: city'
        response[:results][2][:msg].should == 'Required parameter missing: cc'
        response[:results][3][:msg].should == 'Required parameter missing: ident'
        response[:results][4][:msg].should == 'Required parameter missing: voice'
        response[:results][5][:msg].should == 'Required parameter missing: email'

        response[:results][0][:result_code].should == '2003'
        response[:results][1][:result_code].should == '2003'
        response[:results][2][:result_code].should == '2003'
        response[:results][3][:result_code].should == '2003'
        response[:results][4][:result_code].should == '2003'
        response[:results][5][:result_code].should == '2003'

        response[:results].count.should == 6
      end

      it 'successfully saves ident type' do
        xml = { ident: { value: '1990-22-12', attrs: { type: 'birthday' } } }
        epp_plain_request(create_contact_xml(xml), :xml)

        Contact.last.ident_type.should == 'birthday'
      end

      it 'successfully creates a contact' do
        response = epp_plain_request(create_contact_xml, :xml)

        response[:msg].should == 'Command completed successfully'
        response[:result_code].should == '1000'

        @contact = Contact.last

        @contact.registrar.should == registrar1
        registrar1.epp_users.should include(@contact.created_by)
        @contact.updated_by_id.should == nil
        @contact.ident.should == '37605030299'
        @contact.address.street.should == '123 Example'

        log = ApiLog::EppLog.last
        log.request_command.should == 'create'
        log.request_object.should == 'contact'
        log.request_successful.should == true
        log.api_user_name.should == 'gitlab'
        log.api_user_registrar.should == 'Registrar OÜ'
      end

      it 'successfully adds registrar' do
        response = epp_plain_request(create_contact_xml, :xml)

        response[:msg].should == 'Command completed successfully'
        response[:result_code].should == '1000'

        Contact.last.registrar.should == registrar1
      end

      it 'returns result data upon success' do
        response = epp_plain_request(create_contact_xml, :xml)

        response[:msg].should == 'Command completed successfully'
        response[:result_code].should == '1000'

        id =  response[:parsed].css('resData creData id').first
        cr_date =  response[:parsed].css('resData creData crDate').first

        id.text.length.should == 8
        # 5 seconds for what-ever weird lag reasons might happen
        cr_date.text.to_time.should be_within(5).of(Time.now)
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

        response = epp_plain_request(create_contact_xml(xml), :xml)
        response[:result_code].should == '1000'

        @contact = Contact.last
        @contact.disclosure.name.should == true
        @contact.disclosure.org_name.should == true
        @contact.disclosure.phone.should == true
        @contact.disclosure.fax.should == true
        @contact.disclosure.email.should == true
        @contact.disclosure.address.should == true
      end

      it 'creates disclosure data merging with defaults' do
        xml = {
          disclose: { value: {
            voice: { value: '' },
            addr: { value: '' }
          }, attrs: { flag: '1' }
          }
        }

        response = epp_plain_request(create_contact_xml(xml), :xml)
        response[:result_code].should == '1000'

        @contact = Contact.last
        @contact.disclosure.name.should == nil
        @contact.disclosure.org_name.should == nil
        @contact.disclosure.phone.should == true
        @contact.disclosure.fax.should == nil
        @contact.disclosure.email.should == nil
        @contact.disclosure.address.should == true
      end
    end

    context 'update command' do
      before :all do
        @contact = 
          Fabricate(
            :contact,
            created_by_id: 1,
            registrar: registrar1,
            email: 'not_updated@test.test',
            code: 'sh8013',
            auth_info: 'password'
          )
      end

      it 'fails if request is invalid' do
        xml = epp_xml.update
        response = epp_plain_request(xml, :xml) # epp_request('contacts/update_missing_attr.xml')

        response[:results][0][:result_code].should == '2003'
        response[:results][0][:msg].should == 'Required parameter missing: add, rem or chg'
        response[:results][1][:result_code].should == '2003'
        response[:results][1][:msg].should == 'Required parameter missing: id'
        response[:results].count.should == 2
      end

      it 'fails with wrong authentication info' do
        login_as :registrar2 do
          response = epp_plain_request(update_contact_xml({ id: { value: 'sh8013' } }), :xml)
          expect(response[:msg]).to eq('Authorization error')
          expect(response[:result_code]).to eq('2201')
        end
      end

      it 'is succesful' do
        response = epp_plain_request(update_contact_xml({ id: { value: 'sh8013' } }), :xml)

        response[:msg].should == 'Command completed successfully'
        @contact.reload
        @contact.name.should == 'John Doe Edited'
        @contact.email.should == 'edited@example.example'
      end

      it 'returns phone and email error' do
        xml = {
          id: { value: 'sh8013' },
          chg: {
            voice: { value: '123213' },
            email: { value: 'aaa' }
          }
        }

        response = epp_plain_request(update_contact_xml(xml), :xml)

        response[:results][0][:msg].should == 'Phone nr is invalid'
        response[:results][0][:result_code].should == '2005'

        response[:results][1][:msg].should == 'Email is invalid'
        response[:results][1][:result_code].should == '2005'
      end

      it 'updates disclosure items' do
        Fabricate(
          :contact, 
          code: 'sh8013disclosure',
          auth_info: '2fooBAR',
          registrar: registrar1,
          created_by_id: EppUser.first.id,
          disclosure: Fabricate(:contact_disclosure, phone: true, email: true))

        xml = {
          id: { value: 'sh8013disclosure' },
          authInfo: { pw: { value: '2fooBAR' } }
        }
        @response = epp_plain_request(update_contact_xml(xml), :xml)

        @response[:results][0][:msg].should == 'Command completed successfully'
        @response[:results][0][:result_code].should == '1000'

        Contact.last.disclosure.phone.should == false
        Contact.last.disclosure.email.should == false
      end
    end

    context 'delete command' do
      it 'fails if request is invalid' do
        xml = epp_xml.delete({ uid: { value: '23123' } })
        response = epp_plain_request(xml, :xml)

        response[:results][0][:msg].should == 'Required parameter missing: id'
        response[:results][0][:result_code].should == '2003'
        response[:results].count.should == 1
      end

      it 'deletes contact' do
        @contact_deleted =
          Fabricate(:contact, code: 'dwa1234', created_by_id: EppUser.first.id, registrar: registrar1)

        response = epp_plain_request(delete_contact_xml({ id: { value: 'dwa1234' } }), :xml)
        response[:msg].should == 'Command completed successfully'
        response[:result_code].should == '1000'
        response[:clTRID].should == 'ABC-12345'

        Contact.find_by_id(@contact_deleted.id).should == nil
      end

      it 'returns error if obj doesnt exist' do
        response = epp_plain_request(delete_contact_xml, :xml)
        response[:msg].should == 'Object does not exist'
        response[:result_code].should == '2303'
      end

      it 'fails if contact has associated domain' do
        Fabricate(
          :domain,
          registrar: registrar1,
          owner_contact: Fabricate(
            :contact,
            code: 'dwa1234',
            created_by_id: registrar1.id,
            registrar: registrar1)
        )
        Domain.last.owner_contact.address.present?.should == true
        response = epp_plain_request(delete_contact_xml({ id: { value: 'dwa1234' } }), :xml)

        response[:msg].should == 'Object association prohibits operation'
        response[:result_code].should == '2305'

        Domain.last.owner_contact.present?.should == true
      end
    end

    context 'check command' do
      it 'fails if request is invalid' do
        xml = epp_xml.check({ uid: { value: '123asde' } })
        response = epp_plain_request(xml, :xml)

        response[:results][0][:msg].should == 'Required parameter missing: id'
        response[:results][0][:result_code].should == '2003'
        response[:results].count.should == 1
      end

      it 'returns info about contact availability' do
        Fabricate(:contact, code: 'check-1234')

        response = epp_plain_request(check_multiple_contacts_xml, :xml)

        response[:msg].should == 'Command completed successfully'
        response[:result_code].should == '1000'
        ids = response[:parsed].css('resData chkData id')

        ids[0].attributes['avail'].text.should == '0'
        ids[1].attributes['avail'].text.should == '1'

        ids[0].text.should == 'check-1234'
        ids[1].text.should == 'check-4321'
      end
    end

    context 'info command' do
      before :all do
        @registrar1_contact = Fabricate(:contact, code: 'info-4444', registrar: registrar1,
                                        name: 'Johnny Awesome', address: Fabricate(:address))
      end

      it 'return info about contact' do
        login_as :registrar1 do
          xml = epp_xml.info(id: { value: @registrar1_contact.code })
          response = epp_plain_request(xml, :xml)
          response[:msg].should == 'Command completed successfully'
          response[:result_code].should == '1000'

          contact = response[:parsed].css('resData chkData')
          contact.css('name').first.text.should == 'Johnny Awesome'
        end
      end

      it 'fails if request invalid' do
        response = epp_plain_request(epp_xml.info({ wrongid: { value: '123123' } }), :xml)
        response[:results][0][:msg].should == 'Required parameter missing: id'
        response[:results][0][:result_code].should == '2003'
        response[:results].count.should == 1
      end

      it 'returns error when object does not exist' do
        response = epp_plain_request(info_contact_xml({ id: { value: 'no-contact' } }), :xml)
        response[:msg].should == 'Object does not exist'
        response[:result_code].should == '2303'
        response[:results][0][:value].should == 'no-contact'
      end

      # it 'returns auth error for non-owner with wrong password' do
        # @contact = Fabricate(:contact, 
    # registrar: registrar2, code: 'info-4444', name: 'Johnny Awesome', auth_info: 'asde',
                  # address: Fabricate(:address), disclosure: Fabricate(:contact_disclosure, name: false))

        # xml = epp_xml.info({ id: { value: @contact.code }, authInfo: { pw: { value: 'asdesde' } } })
        # response = epp_plain_request(xml, :xml, :registrar1)

        # expect(response[:result_code]).to eq('2200')
        # expect(response[:msg]).to eq('Authentication error')
      # end

      context 'about disclose' do
        # it 'discloses items with wrong password when queried by owner' do
          # @contact = Fabricate(:contact, 
                               # registrar: registrar1, code: 'info-4444', 
                               # name: 'Johnny Awesome', auth_info: 'asde',
                    # address: Fabricate(:address), disclosure: Fabricate(:contact_disclosure, name: false))

          # xml = epp_xml.info({ id: { value: @contact.code } })
          # login_as :registrar1 do
            # response = epp_plain_request(xml, :xml)
            # contact = response[:parsed].css('resData chkData')

            # expect(response[:result_code]).to eq('1000')
            # expect(response[:msg]).to eq('Command completed successfully')
            # expect(contact.css('name').first.text).to eq('Johnny Awesome')
          # end
        # end

        # it 'doesn\'t disclose items to non-owner with right password' do
          # @contact = Fabricate(:contact, registrar: registrar2, code: 'info-4444',
                    # name: 'Johnny Awesome', auth_info: 'password',
                    # address: Fabricate(:address), disclosure: Fabricate(:contact_disclosure, name: false))

          # xml = epp_xml.info({ id: { value: @contact.code }, authInfo: { pw: { value: 'password' } } })
          # response = epp_plain_request(xml, :xml, :registrar1)
          # contact = response[:parsed].css('resData chkData')

          # expect(response[:result_code]).to eq('1000')
          # expect(response[:msg]).to eq('Command completed successfully')
          # expect(contact.css('chkData postalInfo name').first).to eq(nil)
        # end

        # it 'discloses items to owner' do
          # @contact = Fabricate(:contact, registrar: registrar1, code: 'info-4444', name: 'Johnny Awesome',
                    # auth_info: 'password',
                    # address: Fabricate(:address), disclosure: Fabricate(:contact_disclosure, name: false))

          # xml = epp_xml.info({ id: { value: @contact.code } })
          # response = epp_plain_request(xml, :xml, :registrar1)
          # contact = response[:parsed].css('resData chkData')

          # expect(response[:result_code]).to eq('1000')
          # expect(response[:msg]).to eq('Command completed successfully')
          # expect(contact.css('name').first.text).to eq('Johnny Awesome')
        # end

        # it 'doesn\'t disclose private elements' do
          # Fabricate(:contact, code: 'info-4444', auth_info: '2fooBAR', registrar: registrar2,
                    # disclosure: Fabricate(:contact_disclosure, name: true, email: false, phone: false))

          # xml = epp_xml.info({ id: { value: 'info-4444' }, authInfo: { pw: { value: '2fooBAR' } } })

          # response = epp_plain_request(xml, :xml, :registrar1)
          # contact = response[:parsed].css('resData chkData')

          # expect(response[:result_code]).to eq('1000')

          # expect(contact.css('chkData phone')).to eq(contact.css('chkData disclose phone'))
          # expect(contact.css('chkData phone').count).to eq(1)
          # expect(contact.css('chkData email')).to eq(contact.css('chkData disclose email'))
          # expect(contact.css('chkData email').count).to eq(1)
          # expect(contact.css('postalInfo name').present?).to be(true)
        # end
      end

      it 'does not display unassociated object without password' do
        # xml = epp_xml.info(id: { value: @registrar1_contact.code })
        # response = epp_plain_request(xml, :xml, :registrar2)
        # expect(response[:result_code]).to eq('2003')
        # expect(response[:msg]).to eq('Required parameter missing: pw')
      end

      it 'does not display unassociated object with wrong password' do        
        login_as :registrar2
        xml = epp_xml.info(id: { value: @registrar1_contact.code }, 
                           authInfo: { pw: { value: 'wrong-pw' } })
        response = epp_plain_request(xml, :xml)

        response[:msg].should == 'Authentication error'
        response[:result_code].should == '2200'
      end
    end

    context 'renew command' do
      it 'returns 2101-unimplemented command' do
        response = epp_plain_request('contacts/renew.xml')

        response[:msg].should == 'Unimplemented command'
        response[:result_code].should == '2101'
      end
    end
  end

  def registrar1
    @registrar1 ||= Registrar.where(reg_no: '12345678').first || Fabricate(:registrar)
  end

  def registrar2
    @registrar2 ||= Fabricate(:registrar, { name: 'registrar2', reg_no: '123' })
  end

  def epp_xml
    @epp_xml ||= EppXml::Contact.new(cl_trid: 'ABC-12345')
  end
end
