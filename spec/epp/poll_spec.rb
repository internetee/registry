require 'rails_helper'

describe 'EPP Poll', epp: true do
  let(:epp_xml) { EppXml::Session.new }

  def registrar1
    @registrar1 ||= Registrar.where(reg_no: '12345678').first || Fabricate(:registrar)
  end

  def registrar2
    @registrar2 ||= Fabricate(:registrar, { name: 'registrar2', reg_no: '123' })
  end

  before(:all) do
    Fabricate(:epp_user, username: 'registrar1', registrar: registrar1)
    Fabricate(:epp_user, username: 'registrar2', registrar: registrar2)

    login_as :registrar1

    @uniq_no = proc { @i ||= 0; @i += 1 }

    create_settings
  end

  it 'returns no messages in poll' do
    ApiLog::EppLog.delete_all
    response = epp_plain_request(epp_xml.poll, :xml)
    response[:msg].should == 'Command completed successfully; no messages'
    response[:result_code].should == '1300'

    log = ApiLog::EppLog.last

    log.request_command.should == 'poll'
    log.request_object.should == 'poll'
    log.request_successful.should == true
    log.api_user_name.should == 'registrar1'
    log.api_user_registrar.should == 'Registrar OÜ'
    log.request.should_not be_blank
    log.response.should_not be_blank
  end

  it 'queues and dequeues messages' do
    msg = registrar1.messages.create({ body: 'Balance low.' })

    response = login_as :registrar2 do
      epp_plain_request(epp_xml.poll, :xml)
    end

    response[:msg].should == 'Command completed successfully; no messages'
    response[:result_code].should == '1300'

    response = epp_plain_request(epp_xml.poll, :xml)
    response[:msg].should == 'Command completed successfully; ack to dequeue'
    response[:result_code].should == '1301'
    msg_q = response[:parsed].css('msgQ')

    msg_q.css('msg').text.should == 'Balance low.'
    msg_q.first['count'].should == '1'
    msg_q.first['id'].should == msg.id.to_s

    xml = epp_xml.poll(poll: {
      value: '', attrs: { op: 'ack', msgID: msg_q.first['id'] }
    })

    response = login_as :registrar2 do
      epp_plain_request(xml, :xml)
    end

    response[:results][0][:msg].should == 'Message was not found'
    response[:results][0][:result_code].should == '2303'
    response[:results][0][:value].should == msg_q.first['id']

    response = epp_plain_request(xml, :xml)
    response[:msg].should == 'Command completed successfully'
    msg_q = response[:parsed].css('msgQ')
    msg_q.first['id'].should_not be_blank
    msg_q.first['count'].should == '0'

    response = epp_plain_request(xml, :xml)
    response[:results][0][:msg].should == 'Message was not found'
    response[:results][0][:result_code].should == '2303'
    response[:results][0][:value].should == msg_q.first['id']
  end

  it 'returns an error on incorrect op' do
    xml = epp_xml.poll(poll: {
      value: '', attrs: { op: 'bla' }
    })

    response = epp_plain_request(xml, :xml)
    response[:msg].should == 'Attribute is invalid: op'
  end

  it 'dequeues multiple messages' do
    registrar1.messages.create({ body: 'Balance low.' })
    registrar1.messages.create({ body: 'Something.' })
    registrar1.messages.create({ body: 'Smth else.' })

    response = epp_plain_request(epp_xml.poll, :xml)
    response[:msg].should == 'Command completed successfully; ack to dequeue'
    response[:result_code].should == '1301'
    msg_q = response[:parsed].css('msgQ')

    msg_q.css('msg').text.should == 'Smth else.'
    msg_q.first['count'].should == '3'

    xml = epp_xml.poll(poll: {
      value: '', attrs: { op: 'ack', msgID: msg_q.first['id'] }
    })

    response = epp_plain_request(xml, :xml)
    response[:msg].should == 'Command completed successfully'
    msg_q = response[:parsed].css('msgQ')
    msg_q.first['id'].should_not be_blank
    msg_q.first['count'].should == '2'

    response = epp_plain_request(epp_xml.poll, :xml)
    response[:msg].should == 'Command completed successfully; ack to dequeue'
    response[:result_code].should == '1301'
    msg_q = response[:parsed].css('msgQ')

    msg_q.css('msg').text.should == 'Something.'
    msg_q.first['count'].should == '2'

    xml = epp_xml.poll(poll: {
      value: '', attrs: { op: 'ack', msgID: msg_q.first['id'] }
    })

    response = epp_plain_request(xml, :xml)
    response[:msg].should == 'Command completed successfully'
    msg_q = response[:parsed].css('msgQ')
    msg_q.first['id'].should_not be_blank
    msg_q.first['count'].should == '1'

    response = epp_plain_request(epp_xml.poll, :xml)
    response[:msg].should == 'Command completed successfully; ack to dequeue'
    response[:result_code].should == '1301'
    msg_q = response[:parsed].css('msgQ')

    msg_q.css('msg').text.should == 'Balance low.'
    msg_q.first['count'].should == '1'

    xml = epp_xml.poll(poll: {
      value: '', attrs: { op: 'ack', msgID: msg_q.first['id'] }
    })

    response = epp_plain_request(xml, :xml)
    response[:msg].should == 'Command completed successfully'
    msg_q = response[:parsed].css('msgQ')
    msg_q.first['id'].should_not be_blank
    msg_q.first['count'].should == '0'

    response = epp_plain_request(epp_xml.poll, :xml)
    response[:msg].should == 'Command completed successfully; no messages'
    response[:result_code].should == '1300'
  end
end
