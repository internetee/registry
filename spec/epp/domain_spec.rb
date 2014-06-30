require 'rails_helper'

describe 'EPP Domain', epp: true do
  let(:server) { server = Epp::Server.new({server: 'localhost', tag: 'test', password: 'test', port: 701}) }

  context 'with valid user' do
    before(:each) { Fabricate(:epp_user) }

    # incomplete
    it 'creates a domain' do
      response = epp_request('domains/create.xml')
      expect(response[:result_code]).to eq('1000')
      expect(response[:msg]).to eq('Command completed successfully')
      expect(response[:clTRID]).to eq('dpbx005#10-01-29at19:21:47')
      expect(Domain.first.registrar.name).to eq('Zone Media OÜ')
    end

    # incomplete
    it 'checks a domain' do
      response = epp_request('domains/check.xml')
      expect(response[:result_code]).to eq('1000')
      expect(response[:msg]).to eq('Command completed successfully')

      domain = response[:parsed].css('resData chkData cd name').first
      expect(domain.text).to eq('test.ee')
      expect(domain[:avail]).to eq('1')

      Fabricate(:domain, name: 'test.ee')

      response = epp_request('domains/check.xml')
      domain = response[:parsed].css('resData chkData cd name').first
      expect(domain.text).to eq('test.ee')
      expect(domain[:avail]).to eq('0')
    end

    it 'checks multiple domains' do
      response = epp_request('domains/check_multiple.xml')
      expect(response[:result_code]).to eq('1000')
      expect(response[:msg]).to eq('Command completed successfully')

      domain = response[:parsed].css('resData chkData cd name').first
      expect(domain.text).to eq('test.ee')
      expect(domain[:avail]).to eq('1')

      domain = response[:parsed].css('resData chkData cd name').last
      expect(domain.text).to eq('bla.ee')
      expect(domain[:avail]).to eq('1')
    end

    it 'checks invalid format domain' do
      response = epp_request('domains/check_multiple_with_invalid.xml')
      expect(response[:result_code]).to eq('1000')
      expect(response[:msg]).to eq('Command completed successfully')

      domain = response[:parsed].css('resData chkData cd name').first
      expect(domain.text).to eq('test.ee')
      expect(domain[:avail]).to eq('1')

      domain = response[:parsed].css('resData chkData cd').last
      name = domain.css('name').first
      reason = domain.css('reason').first

      expect(name.text).to eq('asdasd')
      expect(name[:avail]).to eq('0')
      expect(reason.text).to eq('invalid format')
    end

  end
end
