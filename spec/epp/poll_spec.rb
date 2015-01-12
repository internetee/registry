require 'rails_helper'

describe 'EPP Poll', epp: true do
  let(:server_zone) { Epp::Server.new({ server: 'localhost', tag: 'zone', password: 'ghyt9e4fu', port: 701 }) }
  let(:server_elkdata) { Epp::Server.new({ server: 'localhost', tag: 'elkdata', password: 'ghyt9e4fu', port: 701 }) }
  let(:elkdata) { Fabricate(:registrar, { name: 'Elkdata', reg_no: '123' }) }
  let(:zone) { Fabricate(:registrar) }
  let(:epp_xml) { EppXml::Session.new }

  before(:each) { create_settings }

  context 'with valid user' do
    before(:each) do
      Fabricate(:epp_user, username: 'zone', registrar: zone)
      Fabricate(:epp_user, username: 'elkdata', registrar: elkdata)
    end

    it 'returns no messages in poll' do
      response = epp_request(epp_xml.poll, :xml)

      expect(response[:msg]).to eq('Command completed successfully; no messages')
      expect(response[:result_code]).to eq('1300')

      log = ApiLog::EppLog.all

      expect(log.length).to eq(4)
      expect(log[0].request_command).to eq('hello')
      expect(log[0].request_successful).to eq(true)

      expect(log[1].request_command).to eq('login')
      expect(log[1].request_successful).to eq(true)
      expect(log[1].api_user_name).to eq('zone')
      expect(log[1].api_user_registrar).to eq('Registrar OÜ')

      expect(log[2].request_command).to eq('poll')
      expect(log[2].request_object).to eq(nil)
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

    it 'queues and dequeues messages' do
      msg = zone.messages.create({ body: 'Balance low.' })

      response = epp_request(epp_xml.poll, :xml, :elkdata)
      expect(response[:msg]).to eq('Command completed successfully; no messages')
      expect(response[:result_code]).to eq('1300')

      response = epp_request(epp_xml.poll, :xml, :zone)
      expect(response[:msg]).to eq('Command completed successfully; ack to dequeue')
      expect(response[:result_code]).to eq('1301')
      msg_q = response[:parsed].css('msgQ')

      expect(msg_q.css('msg').text).to eq('Balance low.')
      expect(msg_q.first['count']).to eq('1')
      expect(msg_q.first['id']).to eq(msg.id.to_s)

      xml = epp_xml.poll(poll: {
        value: '', attrs: { op: 'ack', msgID: msg_q.first['id'] }
      })

      response = epp_request(xml, :xml, :elkdata)
      expect(response[:results][0][:msg]).to eq('Message was not found')
      expect(response[:results][0][:result_code]).to eq('2303')
      expect(response[:results][0][:value]).to eq(msg_q.first['id'])

      response = epp_request(xml, :xml, :zone)
      expect(response[:msg]).to eq('Command completed successfully')
      msg_q = response[:parsed].css('msgQ')
      expect(msg_q.first['id']).to_not be_blank
      expect(msg_q.first['count']).to eq('0')

      response = epp_request(xml, :xml, :zone)
      expect(response[:results][0][:msg]).to eq('Message was not found')
      expect(response[:results][0][:result_code]).to eq('2303')
      expect(response[:results][0][:value]).to eq(msg_q.first['id'])
    end

    it 'returns an error on incorrect op' do
      xml = epp_xml.poll(poll: {
        value: '', attrs: { op: 'bla' }
      })

      response = epp_request(xml, :xml, :zone)
      expect(response[:msg]).to eq('Attribute op is invalid')
    end

    it 'dequeues multiple messages' do
      zone.messages.create({ body: 'Balance low.' })
      zone.messages.create({ body: 'Something.' })
      zone.messages.create({ body: 'Smth else.' })

      response = epp_request(epp_xml.poll, :xml, :zone)
      expect(response[:msg]).to eq('Command completed successfully; ack to dequeue')
      expect(response[:result_code]).to eq('1301')
      msg_q = response[:parsed].css('msgQ')

      expect(msg_q.css('msg').text).to eq('Smth else.')
      expect(msg_q.first['count']).to eq('3')

      xml = epp_xml.poll(poll: {
        value: '', attrs: { op: 'ack', msgID: msg_q.first['id'] }
      })

      response = epp_request(xml, :xml, :zone)
      expect(response[:msg]).to eq('Command completed successfully')
      msg_q = response[:parsed].css('msgQ')
      expect(msg_q.first['id']).to_not be_blank
      expect(msg_q.first['count']).to eq('2')

      response = epp_request(epp_xml.poll, :xml, :zone)
      expect(response[:msg]).to eq('Command completed successfully; ack to dequeue')
      expect(response[:result_code]).to eq('1301')
      msg_q = response[:parsed].css('msgQ')

      expect(msg_q.css('msg').text).to eq('Something.')
      expect(msg_q.first['count']).to eq('2')

      xml = epp_xml.poll(poll: {
        value: '', attrs: { op: 'ack', msgID: msg_q.first['id'] }
      })

      response = epp_request(xml, :xml, :zone)
      expect(response[:msg]).to eq('Command completed successfully')
      msg_q = response[:parsed].css('msgQ')
      expect(msg_q.first['id']).to_not be_blank
      expect(msg_q.first['count']).to eq('1')

      response = epp_request(epp_xml.poll, :xml, :zone)
      expect(response[:msg]).to eq('Command completed successfully; ack to dequeue')
      expect(response[:result_code]).to eq('1301')
      msg_q = response[:parsed].css('msgQ')

      expect(msg_q.css('msg').text).to eq('Balance low.')
      expect(msg_q.first['count']).to eq('1')

      xml = epp_xml.poll(poll: {
        value: '', attrs: { op: 'ack', msgID: msg_q.first['id'] }
      })

      response = epp_request(xml, :xml, :zone)
      expect(response[:msg]).to eq('Command completed successfully')
      msg_q = response[:parsed].css('msgQ')
      expect(msg_q.first['id']).to_not be_blank
      expect(msg_q.first['count']).to eq('0')

      response = epp_request(epp_xml.poll, :xml, :zone)
      expect(response[:msg]).to eq('Command completed successfully; no messages')
      expect(response[:result_code]).to eq('1300')
    end
  end
end
