require 'rails_helper'

describe 'EPP Contact', epp: true do
  before :all do
    create_settings
    create_disclosure_settings
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
          'Required parameter missing: create > create > postalInfo > addr > city [city]'
        response[:results][2][:msg].should == 
          'Required parameter missing: create > create > postalInfo > addr > cc [cc]'
        response[:results][3][:msg].should == 
          'Required parameter missing: create > create > voice [voice]'
        response[:results][4][:msg].should == 
          'Required parameter missing: create > create > email [email]'
        response[:results][5][:msg].should == 
          'Required parameter missing: extension > extdata > ident [ident]'

        response[:results][0][:result_code].should == '2003'
        response[:results][1][:result_code].should == '2003'
        response[:results][2][:result_code].should == '2003'
        response[:results][3][:result_code].should == '2003'
        response[:results][4][:result_code].should == '2003'
        response[:results][5][:result_code].should == '2003'

        response[:results].count.should == 6
      end

      it 'successfully creates a contact' do
        response = create_request

        response[:msg].should == 'Command completed successfully'
        response[:result_code].should == '1000'

        @contact = Contact.last

        @contact.registrar.should == @registrar1
        @registrar1.api_users.should include(@contact.creator)
        @contact.ident.should == '37605030299'
        @contact.address.street.should == '123 Example'
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

        id.text.length.should == 8
        # 5 seconds for what-ever weird lag reasons might happen
        cr_date.text.to_time.should be_within(5).of(Time.now)
      end

      it 'successfully saves custom code' do
        response = create_request({ id: { value: '12345' } })
        response[:msg].should == 'Command completed successfully'
        response[:result_code].should == '1000'

        Contact.last.code.should == 'registrar1:12345'
      end

      it 'should return parameter value policy errror' do
        response = create_request({ postalInfo: { org: { value: 'should not save' } } })
        response[:msg].should == 
          'Parameter value policy error. Org should be blank: postalInfo > org [org]'
        response[:result_code].should == '2306'

        Contact.last.org_name.should == nil
      end
    end

    context 'update command' do
      before :all do
        @contact =
          Fabricate(
            :contact,
            registrar: @registrar1,
            email: 'not_updated@test.test',
            code: 'sh8013'
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
        response[:results][2][:msg].should == 
          'Required parameter missing: update > update > authInfo > pw [pw]'
        response[:results][2][:result_code].should == '2003'
        response[:results].count.should == 3
      end

      it 'returns error if obj doesnt exist' do
        response = update_request({ id: { value: 'not-exists' } })
        response[:msg].should == 'Object does not exist'
        response[:result_code].should == '2303'
        response[:results].count.should == 1
      end

      it 'is succesful' do
        response = update_request({ id: { value: 'sh8013' } })

        response[:msg].should == 'Command completed successfully'
        @contact.reload
        @contact.name.should  == 'John Doe Edited'
        @contact.email.should == 'edited@example.example'
      end

      it 'fails with wrong authentication info' do
        login_as :registrar2 do
          response = update_request({ id: { value: 'sh8013' } })
          response[:msg].should == 'Authorization error'
          response[:result_code].should == '2201'
        end
      end

      it 'returns phone and email error' do
        response = update_request({
          id: { value: 'sh8013' },
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
          id: { value: 'sh8013' },
          chg: {
            id: { value: 'notpossibletoupdate' }
          }
        )

        response[:msg].should == 'Object does not exist'
        response[:result_code].should == '2303'

        @contact.reload.code.should == 'sh8013'
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
        response = update_request({ id: { value: 'sh8013' } }, extension)
        response[:msg].should == 'Command completed successfully'
        response[:result_code].should == '1000'

        Contact.find_by(code: 'sh8013').ident_type.should == 'birthday'
      end

      it 'should return parameter value policy errror for org update' do
        response = update_request({ 
          id: { value: 'sh8013' }, 
          chg: {
            postalInfo: { org: { value: 'should not save' } } 
          }
        })
        response[:msg].should == 
          'Parameter value policy error. Org should be blank: postalInfo > org [org]'
        response[:result_code].should == '2306'

        Contact.find_by(code: 'sh8013').org_name.should == nil
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
        response[:results][1][:msg].should == 
          'Required parameter missing: delete > delete > authInfo > pw [pw]'
        response[:results][1][:result_code].should == '2003'
        response[:results].count.should == 2
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

      it 'fails if contact has associated domain' do
        @domain = Fabricate(:domain, registrar: @registrar1, owner_contact: @contact)
        @domain.owner_contact.address.present?.should == true

        response = delete_request 
        response[:msg].should == 'Object association prohibits operation [domains]'
        response[:result_code].should == '2305'
        response[:results].count.should == 1

        @domain.owner_contact.present?.should == true
      end

      it 'fails with wrong authentication info' do
        login_as :registrar2 do
          response = delete_request
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
        response[:results][0][:value].should == 'no-contact'
        response[:results].count.should == 1
      end

      it 'return info about contact' do
        @registrar1_contact = Fabricate(
          :contact, code: 'info-4444', registrar: @registrar1,
          name: 'Johnny Awesome', address: Fabricate(:address))

        response = info_request({ id: { value: @registrar1_contact.code } })
        response[:msg].should == 'Command completed successfully'
        response[:result_code].should == '1000'

        contact = response[:parsed].css('resData infData')
        contact.css('name').first.text.should == 'Johnny Awesome'
      end

      it 'returns no authorization error for wrong password when owner' do
        response = info_request({ authInfo: { pw: { value: 'wrong-pw' } } })

        response[:msg].should == 'Command completed successfully'
        response[:result_code].should == '1000'
        response[:results].count.should == 1
      end

      it 'returns no authorization error for wrong user but correct pw' do
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

      it 'returns no authorization error for wrong user and wrong pw' do
        login_as :registrar2 do
          response = info_request({ authInfo: { pw: { value: 'wrong-pw' } } })
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

    context 'renew command' do
      it 'returns 2101-unimplemented command' do
        response = epp_plain_request('contacts/renew.xml')

        response[:msg].should == 'Unimplemented command'
        response[:result_code].should == '2101'
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
            <contact:id>check-1234</contact:id>
            <contact:id>check-4321</contact:id>
          </contact:check>
        </check>
        <clTRID>ABC-12345</clTRID>
      </command>
    </epp>'
  end
end
