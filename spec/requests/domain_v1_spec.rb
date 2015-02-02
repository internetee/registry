require 'rails_helper'

describe Repp::DomainV1 do
  before :all do
    create_settings
    @registrar1 = Fabricate(:registrar1)
    @api_user   = Fabricate(:gitlab_api_user, registrar: @registrar1)
  end

  describe 'GET /repp/v1/domains' do
    it 'returns domains of the current registrar' do
      Fabricate.times(2, :domain, registrar: @api_user.registrar)

      get_with_auth '/repp/v1/domains', {}, @api_user
      response.status.should == 200

      body = JSON.parse(response.body)
      body['total_pages'].should == 1

      # TODO: Maybe there is a way not to convert from and to json again
      body['domains'].to_json.should == @api_user.reload.registrar.domains.to_json

      log = ApiLog::ReppLog.last
      log[:request_path].should == '/repp/v1/domains'
      log[:request_method].should == 'GET'
      log[:request_params].should == '{}'
      log[:response_code].should == '200'
      log[:api_user_name].should == 'gitlab'
      log[:api_user_registrar].should == 'registrar1'
      log[:ip].should == '127.0.0.1'
    end
  end
end
