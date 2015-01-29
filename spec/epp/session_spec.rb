require 'rails_helper'

describe 'EPP Session', epp: true do
  before :all do
    @api_user = Fabricate(:api_user)
    @epp_xml = EppXml.new(cl_trid: 'ABC-12345')
    @login_xml_cache = @epp_xml.session.login(clID: { value: 'gitlab' }, pw: { value: 'ghyt9e4fu' })

  end

  context 'when not connected' do
    it 'greets client upon connection' do
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
      response = epp_plain_request(wrong_user, :xml)
      response[:msg].should == 'Authentication error; server closing connection'
      response[:result_code].should == '2501'
      response[:clTRID].should == 'ABC-12345'
    end

    it 'does not log in with inactive user' do
      @registrar = Fabricate(:registrar, { name: 'registrar1', reg_no: '123' })
      Fabricate(:api_user, username: 'inactive-user', active: false, registrar: @registrar)

      inactive = @epp_xml.session.login(clID: { value: 'inactive-user' }, pw: { value: 'ghyt9e4fu' })
      response = epp_plain_request(inactive, :xml)
      response[:result_code].should == '2501'
    end

    it 'prohibits further actions unless logged in' do
      response = epp_plain_request(@epp_xml.domain.create, :xml)
      response[:msg].should == 'You need to login first.'
      response[:result_code].should == '2002'
      response[:clTRID].should == 'ABC-12345'
    end

    context 'with valid user' do
      it 'logs in epp user' do
        response = epp_plain_request(@login_xml_cache, :xml)
        response[:msg].should == 'Command completed successfully'
        response[:result_code].should == '1000'
        response[:clTRID].should == 'ABC-12345'
      end

      it 'does not log in twice' do
        response = epp_plain_request(@login_xml_cache, :xml)
        response[:msg].should == 'Command completed successfully'
        response[:result_code].should == '1000'
        response[:clTRID].should == 'ABC-12345'

        response = epp_plain_request(@login_xml_cache, :xml)
        response[:msg].should match(/Already logged in. Use/)
        response[:result_code].should == '2002'

        log = ApiLog::EppLog.last
        log.request_command.should == 'login'
        log.request_successful.should == false
        log.api_user_name.should == 'gitlab'
        log.api_user_registrar.should == 'Registrar OÜ'
      end

      it 'logs out epp user' do
        epp_plain_request(@login_xml_cache, :xml)

        EppSession.last[:api_user_id].should == 1
        response = epp_plain_request(@epp_xml.session.logout, :xml)
        response[:msg].should == 'Command completed successfully; ending session'
        response[:result_code].should == '1500'

        EppSession.last[:api_user_id].should == nil
      end
    end
  end
end
