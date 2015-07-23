require 'rails_helper'

describe 'EPP Session', epp: true do
  before :all do
    @api_user = Fabricate(:gitlab_api_user)
    @epp_xml = EppXml.new(cl_trid: 'ABC-12345')
    @login_xml_cache = @epp_xml.session.login(clID: { value: 'gitlab' }, pw: { value: 'ghyt9e4fu' })
    @xsd = Nokogiri::XML::Schema(File.read('lib/schemas/epp-1.0.xsd'))
  end

  context 'when not connected' do
    it 'greets client upon connection' do
      server.close_connection
      response = Nokogiri::XML(server.open_connection)
      response.css('epp svID').text.should == 'EPP server (EIS)'
      puts "RESPONSE:\n\n```xml\n#{response}```\n\n" if ENV['EPP_DOC']
    end
  end

  context 'when connected' do
    before do
      server.open_connection
    end

    it 'does not log in with invalid user' do
      wrong_user = @epp_xml.session.login(clID: { value: 'wrong-user' }, pw: { value: 'ghyt9e4fu' })
      response = epp_plain_request(wrong_user)
      response[:msg].should == 'Authentication error; server closing connection (API user not found)'
      response[:result_code].should == '2501'
      response[:clTRID].should == 'ABC-12345'

      log = ApiLog::EppLog.last
      log.request_command.should == 'login'
      log.request_successful.should == false
      log.api_user_name.should == 'api-public'
    end

    it 'does not log in with inactive user' do
      @registrar = Fabricate(:registrar, { name: 'registrar1', reg_no: '123' })
      Fabricate(:api_user, username: 'inactive-user', active: false, registrar: @registrar)

      inactive = @epp_xml.session.login(clID: { value: 'inactive-user' }, pw: { value: 'ghyt9e4fu' })
      response = epp_plain_request(inactive)
      response[:msg].should == 'Authentication error; server closing connection (API user is not active)'
      response[:result_code].should == '2501'

      log = ApiLog::EppLog.last
      log.request_command.should == 'login'
      log.request_successful.should == false
      log.api_user_name.should == '2-api-inactive-user'
    end

    it 'prohibits further actions unless logged in' do
      @xsd = Nokogiri::XML::Schema(File.read('lib/schemas/domain-eis-1.0.xsd'))
      response = epp_plain_request(@epp_xml.domain.info(name: { value: 'test.ee' }))
      response[:msg].should == 'You need to login first.'
      response[:result_code].should == '2002'
      response[:clTRID].should == 'ABC-12345'
    end

    it 'should not have clTRID in response if client does not send it' do
      epp_xml_no_cltrid = EppXml.new(cl_trid: false)
      wrong_user = epp_xml_no_cltrid.session.login(clID: { value: 'wrong-user' }, pw: { value: 'ghyt9e4fu' })
      response = epp_plain_request(wrong_user)
      response[:clTRID].should be_nil
    end

    it 'should return latin only error' do
      wrong_user = @epp_xml.session.login(clID: { value: '你好你好' }, pw: { value: 'ghyt9e4fu' })
      response = epp_plain_request(wrong_user)
      response[:msg].should == 'Parameter value policy error. Allowed only Latin characters.'
      response[:result_code].should == '2306'
      response[:clTRID].should == 'ABC-12345'

      log = ApiLog::EppLog.last
      log.request_command.should == 'login'
      log.request_successful.should == false
      log.api_user_name.should == 'api-public'
    end

    context 'with valid user' do
      it 'logs in epp user' do
        response = epp_plain_request(@login_xml_cache)
        response[:msg].should == 'Command completed successfully'
        response[:result_code].should == '1000'
        response[:clTRID].should == 'ABC-12345'

        log = ApiLog::EppLog.last
        log.request_command.should == 'login'
        log.request_successful.should == true
        log.api_user_name.should == '1-api-gitlab'
      end

      it 'does not log in twice' do
        response = epp_plain_request(@login_xml_cache)
        response[:msg].should == 'Command completed successfully'
        response[:result_code].should == '1000'
        response[:clTRID].should == 'ABC-12345'

        response = epp_plain_request(@login_xml_cache)
        response[:msg].should match(/Already logged in. Use/)
        response[:result_code].should == '2002'

        log = ApiLog::EppLog.last
        log.request_command.should == 'login'
        log.request_successful.should == false
        log.api_user_name.should == '1-api-gitlab'
      end

      it 'logs out epp user' do
        c = EppSession.count
        epp_plain_request(@login_xml_cache)

        EppSession.count.should == c + 1
        response = epp_plain_request(@epp_xml.session.logout)
        response[:msg].should == 'Command completed successfully; ending session'
        response[:result_code].should == '1500'

        EppSession.count.should == c
      end

      it 'changes password and logs in' do
        @api_user.update(password: 'ghyt9e4fu')
        response = epp_plain_request(@epp_xml.session.login(
          clID: { value: 'gitlab' },
          pw: { value: 'ghyt9e4fu' },
          newPW: { value: 'abcdefg' }
        ))

        response[:msg].should == 'Command completed successfully'
        response[:result_code].should == '1000'

        @api_user.reload
        @api_user.password.should == 'abcdefg'
      end

      it 'fails if new password is not valid' do
        @api_user.update(password: 'ghyt9e4fu')
        response = epp_plain_request(@epp_xml.session.login(
          clID: { value: 'gitlab' },
          pw: { value: 'ghyt9e4fu' },
          newPW: { value: '' }
        ), validate_input: false)

        response[:msg].should == 'Password is missing [password]'
        response[:result_code].should == '2306'

        @api_user.reload
        @api_user.password.should == 'ghyt9e4fu'
      end
    end
  end
end
