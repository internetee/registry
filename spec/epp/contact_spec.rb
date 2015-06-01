require 'rails_helper'

describe 'EPP Contact', epp: true do
  before :all do
    @registrar1 = Fabricate(:registrar1)
    @registrar2 = Fabricate(:registrar2)
    @epp_xml    = EppXml::Contact.new(cl_trid: 'ABC-12345')

    Fabricate(:api_user, username: 'registrar1', registrar: @registrar1)
    Fabricate(:api_user, username: 'registrar2', registrar: @registrar2)

    login_as :registrar1

    @contact = Fabricate(:contact, registrar: @registrar1)

    @extension = {
      legalDocument: {
        value: 'JVBERi0xLjQKJcOkw7zDtsOfCjIgMCBvYmoKPDwvTGVuZ3RoIDMgMCBSL0Zp==',
        attrs: { type: 'pdf' }
      },
      ident: {
        value: '37605030299',
        attrs: { type: 'priv', cc: 'EE' }
      }
    }
  end

  context 'with valid user' do
    context 'create command' do
      def create_request(overwrites = {}, extension = {})
        extension = @extension if extension.blank?

        defaults = {
          postalInfo: {
            name: { value: 'John Doe' },
            addr: {
              street: { value: '123 Example' },
              city: { value: 'Tallinn' },
              pc: { value: '123456' },
              cc: { value: 'EE' }
            }
          },
          voice: { value: '+372.1234567' },
          email: { value: 'test@example.example' }
        }
        create_xml = @epp_xml.create(defaults.deep_merge(overwrites), extension)
        epp_plain_request(create_xml, :xml)
      end

      it 'fails if request xml is missing' do
        response = epp_plain_request(@epp_xml.create, :xml)
        response[:results][0][:msg].should ==
          'Required parameter missing: create > create > postalInfo > name [name]'
        response[:results][1][:msg].should ==
          'Required parameter missing: create > create > postalInfo > addr > street [street]'
        response[:results][2][:msg].should ==
          'Required parameter missing: create > create > postalInfo > addr > city [city]'
        response[:results][3][:msg].should ==
          'Required parameter missing: create > create > postalInfo > addr > pc [pc]'
        response[:results][4][:msg].should ==
          'Required parameter missing: create > create > postalInfo > addr > cc [cc]'
        response[:results][5][:msg].should ==
          'Required parameter missing: create > create > voice [voice]'
        response[:results][6][:msg].should ==
          'Required parameter missing: create > create > email [email]'
        response[:results][7][:msg].should ==
          'Required parameter missing: extension > extdata > ident [ident]'

        response[:results][0][:result_code].should == '2003'
        response[:results][1][:result_code].should == '2003'
        response[:results][2][:result_code].should == '2003'
        response[:results][3][:result_code].should == '2003'
        response[:results][4][:result_code].should == '2003'
        response[:results][5][:result_code].should == '2003'
        response[:results][6][:result_code].should == '2003'
        response[:results][7][:result_code].should == '2003'

        response[:results].count.should == 8
      end

      it 'successfully creates a contact' do
        response = create_request

        response[:msg].should == 'Command completed successfully'
        response[:result_code].should == '1000'

        @contact = Contact.last

        @contact.registrar.should == @registrar1
        @registrar1.api_users.should include(@contact.creator)
        @contact.ident.should == '37605030299'
        @contact.street.should == '123 Example'
        @contact.legal_documents.count.should == 1

        log = ApiLog::EppLog.last
        log.request_command.should == 'create'
        log.request_object.should == 'contact'
        log.request_successful.should == true
        log.api_user_name.should == '1-api-registrar1'
        log.api_user_registrar.should == 'registrar1'
      end

      it 'successfully saves ident type' do
        extension = {
          legalDocument: {
            value: 'JVBERi0xLjQKJcOkw7zDtsOfCjIgMCBvYmoKPDwvTGVuZ3RoIDMgMCBSL0Zp==',
            attrs: { type: 'pdf' }
          },
          ident: {
            value: '1990-22-12',
            attrs: { type: 'birthday', cc: 'US' }
          }
        }
        response = create_request({}, extension)

        response[:msg].should == 'Command completed successfully'
        response[:result_code].should == '1000'

        Contact.last.ident_type.should == 'birthday'
      end

      it 'successfully adds registrar' do
        response = create_request

        response[:msg].should == 'Command completed successfully'
        response[:result_code].should == '1000'

        Contact.last.registrar.should == @registrar1
      end

      it 'returns result data upon success' do
        response = create_request

        response[:msg].should == 'Command completed successfully'
        response[:result_code].should == '1000'

        id =  response[:parsed].css('resData creData id').first
        cr_date =  response[:parsed].css('resData creData crDate').first

        id.text.length.should == 15
        # 5 seconds for what-ever weird lag reasons might happen
        cr_date.text.to_time.should be_within(5).of(Time.zone.now)
      end

      it 'should add registrar prefix for code when missing' do
        response = create_request({ id: { value: 'abc12345' } })
        response[:msg].should == 'Command completed successfully'
        response[:result_code].should == '1000'

        Contact.last.code.should == 'FIRST0:ABC12345'
      end

      it 'should add registrar prefix for code when missing' do
        response = create_request({ id: { value: 'abc:ABC:12345' } })
        response[:msg].should == 'Command completed successfully'
        response[:result_code].should == '1000'

        Contact.last.code.should == 'FIRST0:ABC:ABC:12345'
      end

      it 'should not allow spaces in custom code' do
        response = create_request({ id: { value: 'abc 123' } })
        response[:msg].should == 'is invalid [code]'
        response[:result_code].should == '2005'
      end

      it 'should add registrar prefix for code when legacy prefix present' do
        response = create_request({ id: { value: 'CID:FIRST0:abc:ABC:NEW:12345' } })
        response[:msg].should == 'Command completed successfully'
        response[:result_code].should == '1000'

        Contact.last.code.should == 'FIRST0:CID:FIRST0:ABC:ABC:NEW:12345'
      end

      it 'should not remove suffix CID' do
        response = create_request({ id: { value: 'CID:FIRST0:abc:CID:ABC:NEW:12345' } })
        response[:msg].should == 'Command completed successfully'
        response[:result_code].should == '1000'

        Contact.last.code.should == 'FIRST0:CID:FIRST0:ABC:CID:ABC:NEW:12345'
      end

      it 'should not add registrar prefix for code when prefix present' do
        response = create_request({ id: { value: 'FIRST0:abc22' } })
        response[:msg].should == 'Command completed successfully'
        response[:result_code].should == '1000'

        Contact.last.code.should == 'FIRST0:ABC22'
      end

      it 'should add registrar prefix for code does not match exactly to prefix' do
        response = create_request({ id: { value: 'cid2:first0:abc:ABC:11111' } })
        response[:msg].should == 'Command completed successfully'
        response[:result_code].should == '1000'

        Contact.last.code.should == 'FIRST0:CID2:FIRST0:ABC:ABC:11111'
      end

      it 'should ignore custom code when only contact prefix given' do
        response = create_request({ id: { value: 'CID:FIRST0' } })
        response[:msg].should == 'Command completed successfully'
        response[:result_code].should == '1000'

        Contact.last.code.should =~ /FIRST0:..../
      end

      it 'should generate server id when id is empty' do
        response = create_request({ id: { value: '' } })

        response[:msg].should == 'Command completed successfully'
        response[:result_code].should == '1000'

        Contact.last.code.should_not == 'registrar1:'
      end

      it 'should generate server id when id is empty' do
        response = create_request

        response[:msg].should == 'Command completed successfully'
        response[:result_code].should == '1000'

        Contact.last.code.should_not == 'registrar1:'
      end

      it 'should return parameter value policy error for org' do
        response = create_request({ postalInfo: { org: { value: 'should not save' } } })
        response[:msg].should ==
          'Parameter value policy error. Org must be blank: postalInfo > org [org]'
        response[:result_code].should == '2306'

        Contact.last.org_name.should == nil
      end

      it 'should return parameter value policy error for fax' do
        response = create_request({ fax: { value: 'should not save' } })
        response[:msg].should ==
          'Parameter value policy error. Fax must be blank: fax [fax]'
        response[:result_code].should == '2306'

        Contact.last.fax.should == nil
      end
    end

    context 'update command' do
      before :all do
        @contact =
          Fabricate(
            :contact,
            registrar: @registrar1,
            email: 'not_updated@test.test',
            code: 'FIRST0:SH8013'
          )
      end

      def update_request(overwrites = {}, extension = {})
        extension = @extension if extension.blank?

        defaults = {
          id: { value: 'asd123123er' },
          authInfo: { pw: { value: 'password' } },
          chg: {
            postalInfo: {
              name: { value: 'John Doe Edited' }
            },
            voice: { value: '+372.7654321' },
            email: { value: 'edited@example.example' },
            disclose: {
              value: {
                voice: { value: '' },
                email: { value: '' }
              }, attrs: { flag: '0' }
            }
          }
        }
        update_xml = @epp_xml.update(defaults.deep_merge(overwrites), extension)
        epp_plain_request(update_xml, :xml)
      end

      it 'fails if request is invalid' do
        response = epp_plain_request(@epp_xml.update, :xml)

        response[:results][0][:msg].should ==
          'Required parameter missing: add, rem or chg'
        response[:results][0][:result_code].should == '2003'
        response[:results][1][:msg].should ==
          'Required parameter missing: update > update > id [id]'
        response[:results][1][:result_code].should == '2003'
        response[:results].count.should == 2
      end

      it 'returns error if obj doesnt exist' do
        response = update_request({ id: { value: 'not-exists' } })
        response[:msg].should == 'Object does not exist'
        response[:result_code].should == '2303'
        response[:results].count.should == 1
      end

      it 'is succesful' do
        response = update_request({ id: { value: 'FIRST0:SH8013' } })

        response[:msg].should == 'Command completed successfully'

        @contact.reload
        @contact.name.should  == 'John Doe Edited'
        @contact.email.should == 'edited@example.example'
      end

      it 'is succesful for own contact without password' do
        without_password = {
          id: { value: 'FIRST0:SH8013' },
          chg: {
            postalInfo: {
              name: { value: 'John Doe Edited' }
            }
          }
        }
        update_xml = @epp_xml.update(without_password)
        response = epp_plain_request(update_xml, :xml)

        response[:msg].should == 'Command completed successfully'
        @contact.reload
        @contact.name.should  == 'John Doe Edited'
      end

      it 'should update other contact with correct password' do
        login_as :registrar2 do
          response = update_request({ id: { value: 'FIRST0:SH8013' } })
          response[:msg].should == 'Command completed successfully'
          response[:result_code].should == '1000'
        end
      end

      it 'should not update other contact without password' do
        login_as :registrar2 do
          without_password = {
            id: { value: 'FIRST0:SH8013' },
            chg: {
              postalInfo: {
                name: { value: 'John Doe Edited' }
              }
            }
          }
          update_xml = @epp_xml.update(without_password)
          response = epp_plain_request(update_xml, :xml)

          response[:msg].should == 'Authorization error'
          @contact.reload
          @contact.name.should  == 'John Doe Edited'
        end
      end

      it 'returns phone and email error' do
        response = update_request({
          id: { value: 'FIRST0:SH8013' },
          chg: {
            voice: { value: '123213' },
            email: { value: 'wrong' }
          }
        })

        response[:results][0][:msg].should == 'Phone nr is invalid [phone]'
        response[:results][0][:result_code].should == '2005'
        response[:results][1][:msg].should == 'Email is invalid [email]'
        response[:results][1][:result_code].should == '2005'
      end

      it 'should not update code with custom string' do
        response = update_request(
          id: { value: 'FIRST0:SH8013' },
          chg: {
            id: { value: 'notpossibletoupdate' }
          }
        )

        response[:msg].should == 'Object does not exist'
        response[:result_code].should == '2303'

        @contact.reload.code.should == 'FIRST0:SH8013'
      end

      it 'should update ident' do
        extension = {
          legalDocument: {
            value: 'JVBERi0xLjQKJcOkw7zDtsOfCjIgMCBvYmoKPDwvTGVuZ3RoIDMgMCBSL0Zp==',
            attrs: { type: 'pdf' }
          },
          ident: {
            value: '1990-22-12',
            attrs: { type: 'birthday', cc: 'US' }
          }
        }
        response = update_request({ id: { value: 'FIRST0:SH8013' } }, extension)
        response[:msg].should == 'Command completed successfully'
        response[:result_code].should == '1000'

        Contact.find_by(code: 'FIRST0:SH8013').ident_type.should == 'birthday'
      end

      it 'should return parameter value policy errror for org update' do
        response = update_request({
          id: { value: 'FIRST0:SH8013' },
          chg: {
            postalInfo: { org: { value: 'should not save' } }
          }
        })
        response[:msg].should ==
          'Parameter value policy error. Org must be blank: postalInfo > org [org]'
        response[:result_code].should == '2306'

        Contact.find_by(code: 'FIRST0:SH8013').org_name.should == nil
      end

      it 'should return parameter value policy errror for fax update' do
        response = update_request({
          id: { value: 'FIRST0:SH8013' },
          chg: {
            fax: { value: 'should not save' }
          }
        })
        response[:msg].should ==
          'Parameter value policy error. Fax must be blank: fax [fax]'
        response[:result_code].should == '2306'

        Contact.find_by(code: 'FIRST0:SH8013').fax.should == nil
      end

      it 'does not allow to edit statuses if policy forbids it' do
        Setting.client_status_editing_enabled = false

        xml = @epp_xml.update({
          id: { value: 'FIRST0:SH8013' },
          add: [{
            _anonymus: [
              { status: { value: 'Payment overdue.', attrs: { s: 'clientHold', lang: 'en' } } },
              { status: { value: '', attrs: { s: 'clientUpdateProhibited' } } }
            ]
          }]
        })

        response = epp_plain_request(xml, :xml)
        response[:results][0][:result_code].should == '2306'
        response[:results][0][:msg].should == "Parameter value policy error. Client-side object status "\
                                              "management not supported: status [status]"

        Setting.client_status_editing_enabled = true
      end

      it 'should add value voice value' do
        xml = @epp_xml.update({
          id: { value: 'FIRST0:SH8013' },
          authInfo: { pw: { value: 'password' } },
          add: {
            voice: { value: '+372.11111111' }
          }
        })

        response = epp_plain_request(xml, :xml)
        response[:results][0][:msg].should == 'Command completed successfully'
        response[:results][0][:result_code].should == '1000'

        contact = Contact.find_by(code: 'FIRST0:SH8013')
        contact.phone.should == '+372.11111111'

        contact.update_attribute(:phone, '+372.7654321') # restore default value
      end

      it 'should return error when add attributes phone value is empty' do
        xml = @epp_xml.update({
          id: { value: 'FIRST0:SH8013' },
          authInfo: { pw: { value: 'password' } },
          add: {
            voice: { value: '' }
          },
          chg: {
            postalInfo: { email: { value: 'example@example.ee' } }
          }
        })

        response = epp_plain_request(xml, :xml)
        response[:results][0][:msg].should == 'Required parameter missing - phone [phone]'
        response[:results][0][:result_code].should == '2003'
        Contact.find_by(code: 'FIRST0:SH8013').phone.should == '+372.7654321' # aka not changed
      end

      it 'should honor chg value over add value when both changes same attribute' do
        xml = @epp_xml.update({
          id: { value: 'FIRST0:SH8013' },
          authInfo: { pw: { value: 'password' } },
          chg: {
            voice: { value: '+372.2222222222222' }
          },
          add: {
            voice: { value: '+372.11111111111' }
          }
        })

        response = epp_plain_request(xml, :xml)
        response[:results][0][:msg].should == 'Command completed successfully'
        response[:results][0][:result_code].should == '1000'

        contact = Contact.find_by(code: 'FIRST0:SH8013')
        contact.phone.should == '+372.2222222222222'

        contact.update_attribute(:phone, '+372.7654321') # restore default value
      end

      it 'should not allow to remove required voice attribute' do
        xml = @epp_xml.update({
          id: { value: 'FIRST0:SH8013' },
          authInfo: { pw: { value: 'password' } },
          rem: {
            voice: { value: '+372.7654321' }
          }
        })

        response = epp_plain_request(xml, :xml)
        response[:results][0][:msg].should == 'Required parameter missing - phone [phone]'
        response[:results][0][:result_code].should == '2003'

        contact = Contact.find_by(code: 'FIRST0:SH8013')
        contact.phone.should == '+372.7654321'
      end

      it 'should not allow to remove required attribute' do
        xml = @epp_xml.update({
          id: { value: 'FIRST0:SH8013' },
          authInfo: { pw: { value: 'password' } },
          rem: {
            voice: { value: '+372.7654321' }
          }
        })

        response = epp_plain_request(xml, :xml)
        response[:results][0][:msg].should == 'Required parameter missing - phone [phone]'
        response[:results][0][:result_code].should == '2003'

        contact = Contact.find_by(code: 'FIRST0:SH8013')
        contact.phone.should == '+372.7654321'
      end

      it 'should honor add over rem' do
        xml = @epp_xml.update({
          id: { value: 'FIRST0:SH8013' },
          authInfo: { pw: { value: 'password' } },
          rem: {
            voice: { value: 'not important' }
          },
          add: {
            voice: { value: '+372.3333333' }
          }
        })

        response = epp_plain_request(xml, :xml)
        response[:results][0][:msg].should == 'Command completed successfully'
        response[:results][0][:result_code].should == '1000'

        contact = Contact.find_by(code: 'FIRST0:SH8013')
        contact.phone.should == '+372.3333333'

        contact.update_attribute(:phone, '+372.7654321') # restore default value
      end

      it 'should honor chg over rem' do
        xml = @epp_xml.update({
          id: { value: 'FIRST0:SH8013' },
          authInfo: { pw: { value: 'password' } },
          rem: {
            voice: { value: 'not important' }
          },
          chg: {
            voice: { value: '+372.44444444' }
          }
        })

        response = epp_plain_request(xml, :xml)
        response[:results][0][:msg].should == 'Command completed successfully'
        response[:results][0][:result_code].should == '1000'

        contact = Contact.find_by(code: 'FIRST0:SH8013')
        contact.phone.should == '+372.44444444'

        contact.update_attribute(:phone, '+372.7654321') # restore default value
      end

      it 'should honor chg over rem and add' do
        xml = @epp_xml.update({
          id: { value: 'FIRST0:SH8013' },
          authInfo: { pw: { value: 'password' } },
          chg: {
            voice: { value: '+372.666666' }
          },
          add: {
            voice: { value: '+372.555555' }
          },
          rem: {
            voice: { value: 'not important' }
          }
        })

        response = epp_plain_request(xml, :xml)
        response[:results][0][:msg].should == 'Command completed successfully'
        response[:results][0][:result_code].should == '1000'

        contact = Contact.find_by(code: 'FIRST0:SH8013')
        contact.phone.should == '+372.666666'

        contact.update_attribute(:phone, '+372.7654321') # restore default value
      end

      it 'should not remove password' do
        xml = @epp_xml.update({
          id: { value: 'FIRST0:SH8013' },
          authInfo: { pw: { value: 'password' } },
          rem: {
            authInfo: { pw: { value: 'password' } }
          }
        })

        response = epp_plain_request(xml, :xml)
        response[:results][0][:msg].should == 'Command completed successfully'
        response[:results][0][:result_code].should == '1000'

        contact = Contact.find_by(code: 'FIRST0:SH8013')
        contact.auth_info.should == 'password'
      end

      it 'should return general policy error when removing org' do
        xml = @epp_xml.update({
          id: { value: 'FIRST0:SH8013' },
          authInfo: { pw: { value: 'password' } },
          rem: {
            postalInfo: { org: { value: 'not important' } }
          }
        })

        response = epp_plain_request(xml, :xml)
        response[:results][0][:msg].should ==
          'Parameter value policy error. Org must be blank: postalInfo > org [org]'
        response[:results][0][:result_code].should == '2306'
      end

      it 'should return error when removing street' do
        xml = @epp_xml.update({
          id: { value: 'FIRST0:SH8013' },
          authInfo: { pw: { value: 'password' } },
          rem: {
            postalInfo: {
              name: { value: 'not important' }
            }
          }
        })

        response = epp_plain_request(xml, :xml)
        response[:results][0][:msg].should == "Required parameter missing - name [name]"
        response[:results][0][:result_code].should == '2003'
      end
    end

    context 'delete command' do
      before do
        @contact = Fabricate(:contact, registrar: @registrar1)
      end

      def delete_request(overwrites = {})
        defaults = {
          id: { value: @contact.code },
          authInfo: { pw: { value: @contact.auth_info } }
        }
        delete_xml = @epp_xml.delete(defaults.deep_merge(overwrites), @extension)
        epp_plain_request(delete_xml, :xml)
      end

      it 'fails if request is invalid' do
        response = epp_plain_request(@epp_xml.delete, :xml)

        response[:results][0][:msg].should ==
          'Required parameter missing: delete > delete > id [id]'
        response[:results][0][:result_code].should == '2003'
        response[:results].count.should == 1
      end

      it 'returns error if obj doesnt exist' do
        response = delete_request({ id: { value: 'not-exists' } })
        response[:msg].should == 'Object does not exist'
        response[:result_code].should == '2303'
        response[:results].count.should == 1
      end

      it 'deletes contact' do
        response = delete_request
        response[:msg].should == 'Command completed successfully'
        response[:result_code].should == '1000'
        response[:clTRID].should == 'ABC-12345'

        Contact.find_by_id(@contact.id).should == nil
      end

      it 'deletes own contact even with wrong password' do
        response = delete_request({ authInfo: { pw: { value: 'wrong password' } } })
        response[:msg].should == 'Command completed successfully'
        response[:result_code].should == '1000'
        response[:clTRID].should == 'ABC-12345'

        Contact.find_by_id(@contact.id).should == nil
      end

      it 'deletes own contact even without password' do
        delete_xml = @epp_xml.delete({ id: { value: @contact.code } })
        response = epp_plain_request(delete_xml, :xml)
        response[:msg].should == 'Command completed successfully'
        response[:result_code].should == '1000'
        response[:clTRID].should == 'ABC-12345'

        Contact.find_by_id(@contact.id).should == nil
      end

      it 'fails if contact has associated domain' do
        @domain = Fabricate(:domain, registrar: @registrar1, registrant: Registrant.find(@contact.id))
        @domain.registrant.present?.should == true

        response = delete_request
        response[:msg].should == 'Object association prohibits operation [domains]'
        response[:result_code].should == '2305'
        response[:results].count.should == 1

        @domain.registrant.present?.should == true
      end

      it 'should delete when not owner but with correct password' do
        login_as :registrar2 do
          response = delete_request
          response[:msg].should == 'Command completed successfully'
          response[:result_code].should == '1000'
          response[:clTRID].should == 'ABC-12345'
          Contact.find_by_id(@contact.id).should == nil
        end
      end

      it 'should not delete when not owner without password' do
        login_as :registrar2 do
          delete_xml = @epp_xml.delete({ id: { value: @contact.code } })
          response = epp_plain_request(delete_xml, :xml)
          response[:msg].should == 'Authorization error'
          response[:result_code].should == '2201'
          response[:results].count.should == 1
        end
      end

      it 'should not delete when not owner with wrong password' do
        login_as :registrar2 do
          response = delete_request({ authInfo: { value: 'wrong password' } })
          response[:msg].should == 'Authorization error'
          response[:result_code].should == '2201'
          response[:results].count.should == 1
        end
      end
    end

    context 'check command' do
      def check_request(overwrites = {})
        defaults = {
          id: { value: @contact.code },
          authInfo: { pw: { value: @contact.auth_info } }
        }
        xml = @epp_xml.check(defaults.deep_merge(overwrites))
        epp_plain_request(xml, :xml)
      end

      it 'fails if request is invalid' do
        response = epp_plain_request(@epp_xml.check, :xml)

        response[:results][0][:msg].should == 'Required parameter missing: check > check > id [id]'
        response[:results][0][:result_code].should == '2003'
        response[:results].count.should == 1
      end

      it 'returns info about contact availability' do
        contact = Fabricate(:contact, code: 'check-1234')
        contact.code.should == 'FIXED:CHECK-1234'

        response = epp_plain_request(check_multiple_contacts_xml, :xml)

        response[:msg].should == 'Command completed successfully'
        response[:result_code].should == '1000'
        ids = response[:parsed].css('resData chkData id')

        ids[0].attributes['avail'].text.should == '0'
        ids[1].attributes['avail'].text.should == '1'

        ids[0].text.should == 'FIXED:CHECK-1234'
        ids[1].text.should == 'check-4321'
      end

      it 'should support legacy CID farmat' do
        contact = Fabricate(:contact, code: 'check-LEGACY')
        contact.code.should == 'FIXED:CHECK-LEGACY'

        response = epp_plain_request(check_multiple_legacy_contacts_xml, :xml)

        response[:msg].should == 'Command completed successfully'
        response[:result_code].should == '1000'
        ids = response[:parsed].css('resData chkData id')

        ids[0].text.should == 'FIXED:CHECK-LEGACY'
        ids[1].text.should == 'CID:FIXED:CHECK-LEGACY'

        ids[0].attributes['avail'].text.should == '0'
        ids[1].attributes['avail'].text.should == '1'
      end

    end

    context 'info command' do
      def info_request(overwrites = {})
        defaults = {
          id: { value: @contact.code },
          authInfo: { pw: { value: @contact.auth_info } }
        }
        xml = @epp_xml.info(defaults.deep_merge(overwrites))
        epp_plain_request(xml, :xml)
      end

      it 'fails if request invalid' do
        response = epp_plain_request(@epp_xml.info, :xml)
        response[:results][0][:msg].should ==
          'Required parameter missing: info > info > id [id]'
        response[:results][0][:result_code].should == '2003'
        response[:results].count.should == 1
      end

      it 'returns error when object does not exist' do
        response = info_request({ id: { value: 'no-contact' } })
        response[:msg].should == 'Object does not exist'
        response[:result_code].should == '2303'
        response[:results][0][:value].should == 'NO-CONTACT'
        response[:results].count.should == 1
      end

      it 'return info about contact' do
        Fabricate(:contact, code: 'INFO-4444', name: 'Johnny Awesome')

        response = info_request({ id: { value: 'FIXED:INFO-4444' } })
        response[:msg].should == 'Command completed successfully'
        response[:result_code].should == '1000'

        contact = response[:parsed].css('resData infData')
        contact.css('name').first.text.should == 'Johnny Awesome'
      end

      it 'should add legacy CID format as append' do
        Fabricate(:contact, code: 'CID:FIXED:INFO-5555', name: 'Johnny Awesome')

        response = info_request({ id: { value: 'FIXED:CID:FIXED:INFO-5555' } })
        response[:msg].should == 'Command completed successfully'
        response[:result_code].should == '1000'

        contact = response[:parsed].css('resData infData')
        contact.css('name').first.text.should == 'Johnny Awesome'
      end

      it 'should return ident in extension' do
        @registrar1_contact = Fabricate(:contact, code: 'INFO-IDENT',
          registrar: @registrar1, name: 'Johnny Awesome')

        response = info_request({ id: { value: @registrar1_contact.code } })
        response[:msg].should == 'Command completed successfully'
        response[:result_code].should == '1000'

        contact = response[:parsed].css('resData infData')
        contact.css('ident').first.should == nil # ident should be in extension

        contact = response[:parsed].css('extension')
        contact.css('ident').first.text.should == '37605030299'
      end

      it 'returns no authorization error for wrong password when registrant' do
        response = info_request({ authInfo: { pw: { value: 'wrong-pw' } } })

        response[:msg].should == 'Command completed successfully'
        response[:result_code].should == '1000'
        response[:results].count.should == 1
      end

      it 'should honor new contact code format' do
        @registrar1_contact = Fabricate(:contact, code: 'FIXED:test:custom:code')
        @registrar1_contact.code.should == 'FIXED:TEST:CUSTOM:CODE'

        response = info_request({ id: { value: 'FIXED:TEST:CUSTOM:CODE' } })
        response[:msg].should == 'Command completed successfully'
        response[:result_code].should == '1000'

        contact = response[:parsed].css('resData infData')
        contact.css('ident').first.should == nil # ident should be in extension

        contact = response[:parsed].css('extension')
        contact.css('ident').first.text.should == '37605030299'
      end

      it 'returns no authorization error for wrong user but correct password' do
        login_as :registrar2 do
          response = info_request

          response[:msg].should == 'Command completed successfully'
          response[:result_code].should == '1000'
          response[:results].count.should == 1

          contact = response[:parsed].css('resData infData')
          contact.css('postalInfo addr city').first.try(:text).present?.should == true
          contact.css('email').first.try(:text).present?.should == true
          contact.css('voice').first.try(:text).should == '+372.12345678'
        end
      end

      it 'returns authorization error for wrong user and wrong password' do
        login_as :registrar2 do
          response = info_request({ authInfo: { pw: { value: 'wrong-pw' } } })
          response[:msg].should == 'Authorization error'
          response[:result_code].should == '2201'
          response[:results].count.should == 1

          contact = response[:parsed].css('resData infData')
          contact.css('postalInfo addr city').first.try(:text).should == nil
          contact.css('email').first.try(:text).should == nil
          contact.css('voice').first.try(:text).should == nil
        end
      end

      it 'returns no authorization error for wrong user and no password' do
        login_as :registrar2 do
          response = info_request({ authInfo: { pw: { value: '' } } })
          response[:msg].should == 'Command completed successfully'
          response[:result_code].should == '1000'
          response[:results].count.should == 1

          contact = response[:parsed].css('resData infData')
          contact.css('postalInfo addr city').first.try(:text).should == nil
          contact.css('email').first.try(:text).should == nil
          contact.css('voice').first.try(:text).should == nil
        end
      end
    end
  end

  def check_multiple_contacts_xml
    '<?xml version="1.0" encoding="UTF-8" standalone="no"?>
    <epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
      <command>
        <check>
          <contact:check
           xmlns:contact="urn:ietf:params:xml:ns:contact-1.0">
            <contact:id>FIXED:CHECK-1234</contact:id>
            <contact:id>check-4321</contact:id>
          </contact:check>
        </check>
        <clTRID>ABC-12345</clTRID>
      </command>
    </epp>'
  end

  def check_multiple_legacy_contacts_xml
    '<?xml version="1.0" encoding="UTF-8" standalone="no"?>
    <epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
      <command>
        <check>
          <contact:check
           xmlns:contact="urn:ietf:params:xml:ns:contact-1.0">
            <contact:id>FIXED:CHECK-LEGACY</contact:id>
            <contact:id>CID:FIXED:CHECK-LEGACY</contact:id>
          </contact:check>
        </check>
        <clTRID>ABC-12345</clTRID>
      </command>
    </epp>'
  end

end
