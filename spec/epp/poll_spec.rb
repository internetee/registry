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

    expect(response[:msg]).to eq('Command completed successfully; no messages')
    expect(response[:result_code]).to eq('1300')

    log = ApiLog::EppLog.last

    expect(log.request_command).to eq('poll')
    expect(log.request_object).to eq('poll')
    expect(log.request_successful).to eq(true)
    expect(log.api_user_name).to eq('registrar1')
    expect(log.api_user_registrar).to eq('Registrar OÜ')
    expect(log.request).not_to be_blank
    expect(log.response).not_to be_blank
  end

  it 'queues and dequeues messages' do
    msg = registrar1.messages.create({ body: 'Balance low.' })

    response = login_as :registrar2 do
      epp_plain_request(epp_xml.poll, :xml)
    end

    expect(response[:msg]).to eq('Command completed successfully; no messages')
    expect(response[:result_code]).to eq('1300')

    response = epp_plain_request(epp_xml.poll, :xml)
    expect(response[:msg]).to eq('Command completed successfully; ack to dequeue')
    expect(response[:result_code]).to eq('1301')
    msg_q = response[:parsed].css('msgQ')

    expect(msg_q.css('msg').text).to eq('Balance low.')
    expect(msg_q.first['count']).to eq('1')
    expect(msg_q.first['id']).to eq(msg.id.to_s)

    xml = epp_xml.poll(poll: {
      value: '', attrs: { op: 'ack', msgID: msg_q.first['id'] }
    })

    response = login_as :registrar2 do
      epp_plain_request(xml, :xml)
    end

    expect(response[:results][0][:msg]).to eq('Message was not found')
    expect(response[:results][0][:result_code]).to eq('2303')
    expect(response[:results][0][:value]).to eq(msg_q.first['id'])

    response = epp_plain_request(xml, :xml)
    expect(response[:msg]).to eq('Command completed successfully')
    msg_q = response[:parsed].css('msgQ')
    expect(msg_q.first['id']).to_not be_blank
    expect(msg_q.first['count']).to eq('0')

    response = epp_plain_request(xml, :xml)
    expect(response[:results][0][:msg]).to eq('Message was not found')
    expect(response[:results][0][:result_code]).to eq('2303')
    expect(response[:results][0][:value]).to eq(msg_q.first['id'])
  end

  it 'returns an error on incorrect op' do
    xml = epp_xml.poll(poll: {
      value: '', attrs: { op: 'bla' }
    })

    response = epp_plain_request(xml, :xml)
    expect(response[:msg]).to eq('Attribute op is invalid')
  end

  it 'dequeues multiple messages' do
    registrar1.messages.create({ body: 'Balance low.' })
    registrar1.messages.create({ body: 'Something.' })
    registrar1.messages.create({ body: 'Smth else.' })

    response = epp_plain_request(epp_xml.poll, :xml)
    expect(response[:msg]).to eq('Command completed successfully; ack to dequeue')
    expect(response[:result_code]).to eq('1301')
    msg_q = response[:parsed].css('msgQ')

    expect(msg_q.css('msg').text).to eq('Smth else.')
    expect(msg_q.first['count']).to eq('3')

    xml = epp_xml.poll(poll: {
      value: '', attrs: { op: 'ack', msgID: msg_q.first['id'] }
    })

    response = epp_plain_request(xml, :xml)
    expect(response[:msg]).to eq('Command completed successfully')
    msg_q = response[:parsed].css('msgQ')
    expect(msg_q.first['id']).to_not be_blank
    expect(msg_q.first['count']).to eq('2')

    response = epp_plain_request(epp_xml.poll, :xml)
    expect(response[:msg]).to eq('Command completed successfully; ack to dequeue')
    expect(response[:result_code]).to eq('1301')
    msg_q = response[:parsed].css('msgQ')

    expect(msg_q.css('msg').text).to eq('Something.')
    expect(msg_q.first['count']).to eq('2')

    xml = epp_xml.poll(poll: {
      value: '', attrs: { op: 'ack', msgID: msg_q.first['id'] }
    })

    response = epp_plain_request(xml, :xml)
    expect(response[:msg]).to eq('Command completed successfully')
    msg_q = response[:parsed].css('msgQ')
    expect(msg_q.first['id']).to_not be_blank
    expect(msg_q.first['count']).to eq('1')

    response = epp_plain_request(epp_xml.poll, :xml)
    expect(response[:msg]).to eq('Command completed successfully; ack to dequeue')
    expect(response[:result_code]).to eq('1301')
    msg_q = response[:parsed].css('msgQ')

    expect(msg_q.css('msg').text).to eq('Balance low.')
    expect(msg_q.first['count']).to eq('1')

    xml = epp_xml.poll(poll: {
      value: '', attrs: { op: 'ack', msgID: msg_q.first['id'] }
    })

    response = epp_plain_request(xml, :xml)
    expect(response[:msg]).to eq('Command completed successfully')
    msg_q = response[:parsed].css('msgQ')
    expect(msg_q.first['id']).to_not be_blank
    expect(msg_q.first['count']).to eq('0')

    response = epp_plain_request(epp_xml.poll, :xml)
    expect(response[:msg]).to eq('Command completed successfully; no messages')
    expect(response[:result_code]).to eq('1300')
  end
end
