require 'rails_helper'

describe 'EPP Keyrelay', epp: true do
  let(:server_zone) { Epp::Server.new({ server: 'localhost', tag: 'zone', password: 'ghyt9e4fu', port: 701 }) }
  let(:server_elkdata) { Epp::Server.new({ server: 'localhost', tag: 'elkdata', password: 'ghyt9e4fu', port: 701 }) }
  let(:epp_xml) { EppXml::Keyrelay.new }

  before(:each) { create_settings }

  before(:all) do
    @elkdata = Fabricate(:registrar, { name: 'Elkdata', reg_no: '123' })
    @zone = Fabricate(:registrar)
    Fabricate(:epp_user, username: 'zone', registrar: @zone)
    Fabricate(:epp_user, username: 'elkdata', registrar: @elkdata)

    @uniq_no = proc { @i ||= 0; @i += 1 }
  end

  before(:each) { Fabricate(:domain, name: next_domain_name, registrar: @zone, dnskeys: [Fabricate.build(:dnskey)]) }
  let(:domain) { Domain.last }

  it 'makes a keyrelay request' do
    ApiLog::EppLog.delete_all

    xml = epp_xml.keyrelay({
      name: { value: domain.name },
      keyData: {
        flags: { value: '256' },
        protocol: { value: '3' },
        alg: { value: '8' },
        pubKey: { value: 'cmlraXN0aGViZXN0' }
      },
      authInfo: {
        pw: { value: domain.auth_info }
      },
      expiry: {
        relative: { value: 'P1M13D' }
      }
    })

    response = epp_request(xml, :xml, :elkdata)

    response[:msg].should == 'Command completed successfully'
    response[:result_code].should == '1000'

    @zone.messages.queued.count.should == 1

    log = ApiLog::EppLog.all

    log.length.should == 4
    log[0].request_command.should == 'hello'
    log[0].request_successful.should == true

    log[1].request_command.should == 'login'
    log[1].request_successful.should == true
    log[1].api_user_name.should == 'elkdata'
    log[1].api_user_registrar.should == 'Elkdata'

    log[2].request_command.should == 'keyrelay'
    log[2].request_object.should == 'keyrelay'
    log[2].request_successful.should == true
    log[2].api_user_name.should == 'elkdata'
    log[2].api_user_registrar.should == 'Elkdata'
    log[2].request.should_not be_blank
    log[2].response.should_not be_blank

    log[3].request_command.should == 'logout'
    log[3].request_successful.should == true
    log[3].api_user_name.should == 'elkdata'
    log[3].api_user_registrar.should == 'Elkdata'
  end

  it 'returns an error when parameters are missing' do
    msg_count = @zone.messages.queued.count
    xml = epp_xml.keyrelay({
      name: { value: domain.name },
      keyData: {
        protocol: { value: '3' },
        alg: { value: '8' },
        pubKey: { value: 'cmlraXN0aGViZXN0' }
      },
      authInfo: {
        pw: { value: domain.auth_info }
      },
      expiry: {
        relative: { value: 'Invalid Expiry' }
      }
    })

    response = epp_request(xml, :xml, :elkdata)
    response[:msg].should == 'Required parameter missing: keyData > flags'

    @zone.messages.queued.count.should == msg_count
  end

  it 'returns an error on invalid relative expiry' do
    msg_count = @zone.messages.queued.count
    xml = epp_xml.keyrelay({
      name: { value: domain.name },
      keyData: {
        flags: { value: '256' },
        protocol: { value: '3' },
        alg: { value: '8' },
        pubKey: { value: 'cmlraXN0aGViZXN0' }
      },
      authInfo: {
        pw: { value: domain.auth_info }
      },
      expiry: {
        relative: { value: 'Invalid Expiry' }
      }
    })

    response = epp_request(xml, :xml, :elkdata)
    response[:msg].should == 'Expiry relative must be compatible to ISO 8601'
    response[:results][0][:value].should == 'Invalid Expiry'

    @zone.messages.queued.count.should == msg_count
  end

  it 'returns an error on invalid absolute expiry' do
    msg_count = @zone.messages.queued.count
    xml = epp_xml.keyrelay({
      name: { value: domain.name },
      keyData: {
        flags: { value: '256' },
        protocol: { value: '3' },
        alg: { value: '8' },
        pubKey: { value: 'cmlraXN0aGViZXN0' }
      },
      authInfo: {
        pw: { value: domain.auth_info }
      },
      expiry: {
        absolute: { value: 'Invalid Absolute' }
      }
    })

    response = epp_request(xml, :xml, :elkdata)
    response[:msg].should == 'Expiry absolute must be compatible to ISO 8601'
    response[:results][0][:value].should == 'Invalid Absolute'

    @zone.messages.queued.count.should == msg_count
  end

  it 'does not allow both relative and absolute' do
    msg_count = @zone.messages.queued.count
    xml = epp_xml.keyrelay({
      name: { value: domain.name },
      keyData: {
        flags: { value: '256' },
        protocol: { value: '3' },
        alg: { value: '8' },
        pubKey: { value: 'cmlraXN0aGViZXN0' }
      },
      authInfo: {
        pw: { value: domain.auth_info }
      },
      expiry: {
        relative: { value: 'P1D' },
        absolute: { value: '2014-12-23' }
      }
    })

    response = epp_request(xml, :xml, :elkdata)
    response[:msg].should == 'Exactly one parameter required: expiry > relative or expiry > absolute'

    @zone.messages.queued.count.should == msg_count
  end
end
