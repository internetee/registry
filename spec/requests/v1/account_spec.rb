require 'rails_helper'

describe Repp::AccountV1 do
  it 'should fail without whitelisted IP' do
    ENV['webclient_ips'] = '192.188.1.1'
    Setting.api_ip_whitelist_enabled = true
    @registrar1 = Fabricate(:registrar, white_ips: [Fabricate(:white_ip_registrar, ipv4: '99.99.99.99')])
    @api_user = Fabricate(:api_user, registrar: @registrar1)

    get_with_auth '/repp/v1/accounts/balance', {}, @api_user
    response.status.should == 401
    body = JSON.parse(response.body)

    body['error'].should == 'IP is not whitelisted'
    ENV['webclient_ips'] = '127.0.0.1'
    Setting.api_ip_whitelist_enabled = false
  end

  context 'with valid registrar' do
    before :all do
      @registrar1 = Fabricate(:registrar1)
      @registrar1.accounts = [Fabricate(:account, { balance: '324.45', account_activities: [] })]
      @registrar1.save
      @api_user = Fabricate(:gitlab_api_user, registrar: @registrar1)
    end

    describe 'GET /repp/v1/accounts/balance' do
      it 'returns account balance of the current registrar', autodoc: true, route_info_doc: true do
        get_with_auth '/repp/v1/accounts/balance', {}, @api_user
        response.status.should == 200

        body = JSON.parse(response.body)
        body['balance'].should == '324.45'
        body['currency'].should == 'EUR'

        log = ApiLog::ReppLog.last
        log[:request_path].should == '/repp/v1/accounts/balance'
        log[:request_method].should == 'GET'
        log[:request_params].should == '{}'
        log[:response_code].should == '200'
        log[:api_user_name].should == 'gitlab'
        log[:api_user_registrar].should == 'registrar1'
        log[:ip].should == '127.0.0.1'
      end
    end
  end
end
