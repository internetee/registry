require 'rails_helper'

describe 'EPP Keyrelay', epp: true do
  before(:all) do
    @registrar1 = Fabricate(:registrar1)
    @registrar2 = Fabricate(:registrar2)
    @domain     = Fabricate(:domain, registrar: @registrar2)
    @epp_xml    = EppXml::Keyrelay.new

    Fabricate(:api_user, username: 'registrar1', registrar: @registrar1)
    Fabricate(:api_user, username: 'registrar2', registrar: @registrar2)

    login_as :registrar1
  end

  it 'makes a keyrelay request' do
    ApiLog::EppLog.delete_all

    xml = @epp_xml.keyrelay({
      name: { value: @domain.name },
      keyData: {
        flags: { value: '256' },
        protocol: { value: '3' },
        alg: { value: '8' },
        pubKey: { value: 'cmlraXN0aGViZXN0' }
      },
      authInfo: {
        pw: { value: @domain.auth_info }
      },
      expiry: {
        relative: { value: 'P1M13D' }
      }
    })

    response = epp_plain_request(xml, :xml)

    response[:msg].should == 'Unimplemented object service'
    response[:result_code].should == '2307'

    # response[:msg].should == 'Command completed successfully'
    # response[:result_code].should == '1000'

    # @registrar2.messages.queued.count.should == 1

    # log = ApiLog::EppLog.last
    # log.request_command.should == 'keyrelay'
    # log.request_successful.should == true
    # log.api_user_name.should == '1-api-registrar1'
  end

  it 'returns an error when parameters are missing' do
    msg_count = @registrar2.messages.queued.count
    xml = @epp_xml.keyrelay({
      name: { value: @domain.name },
      keyData: {
        protocol: { value: '3' },
        alg: { value: '8' },
        pubKey: { value: 'cmlraXN0aGViZXN0' }
      },
      authInfo: {
        pw: { value: @domain.auth_info }
      },
      expiry: {
        relative: { value: 'Invalid Expiry' }
      }
    })

    response = epp_plain_request(xml, :xml)
    response[:msg].should == 'Required parameter missing: keyrelay > keyData > flags [flags]'

    @registrar2.messages.queued.count.should == msg_count
  end

  it 'returns an error on invalid relative expiry' do
    msg_count = @registrar2.messages.queued.count
    xml = @epp_xml.keyrelay({
      name: { value: @domain.name },
      keyData: {
        flags: { value: '256' },
        protocol: { value: '3' },
        alg: { value: '8' },
        pubKey: { value: 'cmlraXN0aGViZXN0' }
      },
      authInfo: {
        pw: { value: @domain.auth_info }
      },
      expiry: {
        relative: { value: 'Invalid Expiry' }
      }
    })

    response = epp_plain_request(xml, :xml)
    response[:msg].should == 'Expiry relative must be compatible to ISO 8601'
    response[:results][0][:value].should == 'Invalid Expiry'

    @registrar2.messages.queued.count.should == msg_count
  end

  it 'returns an error on invalid absolute expiry' do
    msg_count = @registrar2.messages.queued.count
    xml = @epp_xml.keyrelay({
      name: { value: @domain.name },
      keyData: {
        flags: { value: '256' },
        protocol: { value: '3' },
        alg: { value: '8' },
        pubKey: { value: 'cmlraXN0aGViZXN0' }
      },
      authInfo: {
        pw: { value: @domain.auth_info }
      },
      expiry: {
        absolute: { value: 'Invalid Absolute' }
      }
    })

    response = epp_plain_request(xml, :xml)
    response[:msg].should == 'Expiry absolute must be compatible to ISO 8601'
    response[:results][0][:value].should == 'Invalid Absolute'

    @registrar2.messages.queued.count.should == msg_count
  end

  # keyrelay not enabled at the moment
  # it 'does not allow both relative and absolute' do
    # msg_count = @registrar2.messages.queued.count
    # xml = @epp_xml.keyrelay({
      # name: { value: @domain.name },
      # keyData: {
        # flags: { value: '256' },
        # protocol: { value: '3' },
        # alg: { value: '8' },
        # pubKey: { value: 'cmlraXN0aGViZXN0' }
      # },
      # authInfo: {
        # pw: { value: @domain.auth_info }
      # },
      # expiry: {
        # relative: { value: 'P1D' },
        # absolute: { value: '2014-12-23' }
      # }
    # })

    # response = epp_plain_request(xml, :xml)
    # response[:msg].should == 'Exactly one parameter required: keyrelay > expiry > relative OR '\
    # 'keyrelay > expiry > absolute'

    # @registrar2.messages.queued.count.should == msg_count
  # end

  it 'saves legal document with keyrelay' do
    xml = @epp_xml.keyrelay({
      name: { value: @domain.name },
      keyData: {
        flags: { value: '256' },
        protocol: { value: '3' },
        alg: { value: '8' },
        pubKey: { value: 'cmlraXN0aGViZXN0' }
      },
      authInfo: {
        pw: { value: @domain.auth_info }
      },
      expiry: {
        relative: { value: 'P1D' }
      }
    }, {
      _anonymus: [
        legalDocument: {
          value: 'JVBERi0xLjQKJcOkw7zDtsOfCjIgMCBvYmoKPDwvTGVuZ3RoIDMgMCBSL0Zp==',
          attrs: { type: 'pdf' }
        }
      ]
    })

    response = epp_plain_request(xml, :xml)

    response[:msg].should == 'Unimplemented object service'
    response[:result_code].should == '2307'

    # response[:msg].should == 'Command completed successfully'

    # docs = Keyrelay.last.legal_documents
    # docs.count.should == 1
    # docs.first.path.should_not be_blank
    # docs.first.document_type.should == 'pdf'
  end

  it 'validates legal document types' do
    xml = @epp_xml.keyrelay({
      name: { value: @domain.name },
      keyData: {
        flags: { value: '256' },
        protocol: { value: '3' },
        alg: { value: '8' },
        pubKey: { value: 'cmlraXN0aGViZXN0' }
      },
      authInfo: {
        pw: { value: @domain.auth_info }
      },
      expiry: {
        relative: { value: 'P1D' }
      }
    }, {
      _anonymus: [
        legalDocument: {
          value: 'JVBERi0xLjQKJcOkw7zDtsOfCjIgMCBvYmoKPDwvTGVuZ3RoIDMgMCBSL0Zp==',
          attrs: { type: 'jpg' }
        }
      ]
    })

    response = epp_plain_request(xml, :xml)
    response[:msg].should == 'Attribute is invalid: type'
  end
end
